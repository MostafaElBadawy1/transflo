import CoreGraphics
import Foundation
import TransfloDomain

/// Image tools: Compress, Rotate & flip, Resize, Crop, Adjust, Remove metadata,
/// Remove background, Read QR / barcode (images and PDF) and Images → PDF.
public struct ImageToolEngine: ToolEngine {
    static let editable: Set<String> = ["jpg", "png", "heic", "tiff", "bmp", "webp", "avif", "gif"]
    static let tools: Set<ToolKind> = [
        .compress, .rotate, .resize, .crop, .adjust, .removeMetadata, .removeBackground, .readCode, .imagesToPDF,
        .annotate, .redact, .addBackground, .collage, .editMetadata
    ]

    private let writer: ImageFileWriter
    private let naming: ToolOutputNaming
    private let copier: any TextCopying

    public init(ffmpeg: URL?, naming: ToolOutputNaming, copier: any TextCopying) {
        self.writer = ImageFileWriter(ffmpeg: ffmpeg)
        self.naming = naming
        self.copier = copier
    }

    public func canRun(_ tool: ToolKind, on formats: [FormatDescriptor?]) -> Bool {
        guard Self.tools.contains(tool), !formats.isEmpty else { return false }
        let ids = formats.map { $0?.id.rawValue ?? "" }
        switch tool {
        case .readCode:
            return ids.allSatisfy { Self.editable.contains($0) || $0 == "pdf" }
        case .imagesToPDF, .collage:
            return ids.count >= 2 && ids.allSatisfy(Self.editable.contains)
        case .editMetadata:
            return ids.allSatisfy { Self.editable.contains($0) && $0 != "webp" && writer.canWrite($0) }
        case .compress:
            return ids.allSatisfy { ImageCompressor.compressible.contains($0) && writer.canWrite($0) }
        default:
            return ids.allSatisfy { Self.editable.contains($0) && writer.canWrite($0) }
        }
    }

    public func run(
        _ request: ToolRequest,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws(JobError) -> [URL] {
        try await BlockingWork.runCancellable { [self] isCancelled throws(JobError) -> [URL] in
            switch request.tool {
            case .readCode:
                return try readCodes(request.items, isCancelled: isCancelled)
            case .imagesToPDF:
                return try imagesToPDF(request.items, isCancelled: isCancelled)
            case .collage:
                return try collage(request.items, settings: request.settings, isCancelled: isCancelled)
            default:
                return try perFile(request, isCancelled: isCancelled, progress: progress)
            }
        }
    }

    private func perFile(
        _ request: ToolRequest, isCancelled: () -> Bool, progress: (Double) -> Void
    ) throws(JobError) -> [URL] {
        var outputs: [URL] = []
        do throws(JobError) {
            for (index, item) in request.items.enumerated() {
                if isCancelled() { throw .cancelled }
                outputs.append(try apply(request.tool, settings: request.settings, to: item, isCancelled: isCancelled))
                progress(Double(index + 1) / Double(request.items.count))
            }
        } catch {
            throw outputs.isEmpty ? error : .partialFailure(completed: outputs, cause: error)
        }
        return outputs
    }

    private func apply(
        _ tool: ToolKind, settings: ToolSettings, to item: ToolItem, isCancelled: () -> Bool
    ) throws(JobError) -> URL {
        let format = item.format?.id.rawValue ?? ""
        // WebP is encoded by ffmpeg, whose image path does not persist these ImageIO tags.
        if tool == .editMetadata && format == "webp" { throw .unsupported }
        let output = try naming.destination(
            for: item.url, tool: tool, pathExtension: tool == .removeBackground ? "png" : nil
        )
        do throws(JobError) {
            switch (tool, settings) {
            case let (.compress, .compress(.level(level))):
                try ImageCompressor.compress(item.url, format: format, level: level, writer: writer, to: output)
            case let (.compress, .compress(.targetBytes(bytes))):
                try TargetImageCompressor.compress(item.url, budget: (format, bytes), writer: writer,
                                                   to: output, isCancelled: isCancelled)
            case (.removeMetadata, _):
                try writer.write(try ImageDecoding.decodeUpright(item.url).image, format: format, to: output)
            case let (.editMetadata, .metadata(values)):
                let decoded = try ImageDecoding.decodeUpright(item.url)
                let properties = ImageMetadataWriter.properties(decoded.properties, applying: values)
                try writer.write(decoded.image, format: format, properties: properties, to: output)
            case (.removeBackground, _):
                let original = try ImageDecoding.decodeUpright(item.url).image
                try PNGWriter.write(try VisionImageTools.removeBackground(from: original), to: output)
            default:
                let decoded = try ImageDecoding.decodeUpright(item.url)
                let image = try edited(decoded.image, settings: settings)
                try writer.write(image, format: format, properties: decoded.properties, to: output)
            }
        } catch JobError.destinationOccupied {
            throw .destinationOccupied
        } catch {
            throw error
        }
        return output
    }

    /// Pixel edits that keep the file's format and metadata: rotate, resize, crop, adjust.
    private func edited(_ image: CGImage, settings: ToolSettings) throws(JobError) -> CGImage {
        let result: CGImage? = switch settings {
        case let .rotate(turns, flipH, flipV):
            ImageScaling.rotate(image, quarterTurns: turns, flipHorizontal: flipH, flipVertical: flipV)
        case let .resize(width, height) where width > 0 && height > 0:
            ImageScaling.draw(image, width: width, height: height) {
                $0.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        case let .crop(rect):
            image.cropping(to: Self.frame(rect.pixels(width: image.width, height: image.height)))
        case let .adjust(adjustments):
            try ImageAdjuster.apply(adjustments, to: image)
        case let .annotate(annotations):
            ImageMarkup.annotate(image, with: annotations)
        case let .redact(boxes):
            ImageMarkup.redact(image, boxes: boxes)
        case let .addBackground(style):
            try BackgroundComposer.compose(image, style: style)
        default:
            throw .unsupported
        }
        guard let result else { throw .failed }
        return result
    }

    private static func frame(_ pixels: PixelRect) -> CGRect {
        CGRect(x: pixels.x, y: pixels.y, width: pixels.width, height: pixels.height)
    }

    private func readCodes(_ items: [ToolItem], isCancelled: () -> Bool) throws(JobError) -> [URL] {
        var codes: [String] = []
        for item in items {
            if isCancelled() { throw .cancelled }
            let found = try RasterLimits.withPool { () throws(JobError) -> [String] in
                if item.format?.id.rawValue == "pdf" {
                    return try VisionImageTools.codes(inPDF: item.url, isCancelled: isCancelled)
                }
                return VisionImageTools.codes(in: [try ImageDecoding.decodeUpright(item.url).image])
            }
            for code in found where !codes.contains(code) { codes.append(code) }
        }
        if isCancelled() { throw .cancelled }
        guard !codes.isEmpty else { throw .nothingFound }
        copier.copy(codes.joined(separator: "\n"))
        return []
    }

    private func collage(
        _ items: [ToolItem], settings: ToolSettings, isCancelled: () -> Bool
    ) throws(JobError) -> [URL] {
        guard case let .collage(columns, spacing, background) = settings, let first = items.first else {
            throw .unsupported
        }
        if isCancelled() { throw .cancelled }
        let image = try ImageDecoding.decodeUpright(first.url, longEdge: 1200).image
        let grid = try ImageMarkup.collage(first: image, layout: (columns, spacing),
                                          background: background, count: items.count) { index throws(JobError) in
            if isCancelled() { throw .cancelled }
            return try ImageDecoding.decodeUpright(items[index].url, longEdge: 1200).image
        }
        if isCancelled() { throw .cancelled }
        let output = try naming.destination(for: first.url, tool: .collage, pathExtension: "png")
        do throws(JobError) {
            try PNGWriter.write(grid, to: output)
            return [output]
        } catch {
            throw error
        }
    }

    private func imagesToPDF(_ items: [ToolItem], isCancelled: () -> Bool) throws(JobError) -> [URL] {
        guard let first = items.first else { throw .failed }
        if isCancelled() { throw .cancelled }
        let output = try naming.destination(for: first.url, tool: .imagesToPDF, pathExtension: "pdf")
        try OutputFile.write(to: output) { staged throws(JobError) in
            try writePDF(items, to: staged, isCancelled: isCancelled)
        }
        return [output]
    }

    private func writePDF(_ items: [ToolItem], to output: URL, isCancelled: () -> Bool) throws(JobError) {
        var mediaBox = CGRect(x: 0, y: 0, width: 1, height: 1)
        guard let context = CGContext(output as CFURL, mediaBox: &mediaBox, nil) else { throw .destinationUnavailable }
        do throws(JobError) {
            for item in items {
                if isCancelled() { throw .cancelled }
                try RasterLimits.withPool { () throws(JobError) in
                    let page = try ImageDecoding.decodeUpright(item.url)
                    var box = CGRect(origin: .zero, size: page.pointSize)
                    let info = [kCGPDFContextMediaBox as String: Data(bytes: &box, count: MemoryLayout<CGRect>.size)]
                    context.beginPDFPage(info as CFDictionary)
                    context.draw(page.image, in: box)
                    context.endPDFPage()
                }
            }
            if isCancelled() { throw .cancelled }
            context.closePDF()
        } catch {
            context.closePDF()
            throw error
        }
    }
}
