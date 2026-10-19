import CoreGraphics
import Foundation
import ImageIO
import PDFKit
import TransfloDomain

/// Editor previews: ImageIO for images, ffprobe and a frame grab for video and audio, PDFKit for PDFs.
public struct MediaToolPreviewProvider: ToolPreviewProviding {
    static let thumbnailLongEdge = 900
    static let pageThumbnailLongEdge: CGFloat = 160

    private let ffmpeg: URL?
    private let ffprobe: URL?

    public init(ffmpeg: URL?, ffprobe: URL?) {
        self.ffmpeg = ffmpeg
        self.ffprobe = ffprobe
    }

    public func preview(of url: URL, format: FormatDescriptor?) async -> ToolPreview {
        switch format?.family {
        case .image:
            return (try? await BlockingWork.run { () throws(JobError) in try Self.imagePreview(url) }) ?? .empty
        case .video, .audio:
            guard let ffprobe, let info = try? await FFprobe.info(binary: ffprobe, file: url) else { return .empty }
            let thumbnail = info.hasVideo ? await frame(of: url, at: min(1, (info.duration ?? 0) / 10)) : nil
            return ToolPreview(width: info.width, height: info.height, duration: info.duration, pageCount: nil,
                               thumbnail: thumbnail)
        default:
            guard format?.id.rawValue == "pdf" else { return .empty }
            return (try? await BlockingWork.run { () throws(JobError) in try Self.pdfPreview(url) }) ?? .empty
        }
    }

    public func frame(of url: URL, at seconds: Double) async -> Data? {
        guard let ffmpeg, let workspace = try? TemporaryWorkspace() else { return nil }
        defer { workspace.remove() }
        let output = workspace.url.appendingPathComponent("frame.png")
        let scale = "scale='min(iw\\,\(Self.thumbnailLongEdge))':-2"
        let arguments = ["-hide_banner", "-nostdin", "-loglevel", "error", "-ss", MediaEditArguments.seconds(seconds),
                         "-i", url.path, "-frames:v", "1", "-update", "1", "-vf", scale, output.path]
        let status = await ProcessRunner.run(
            executable: ffmpeg, arguments: arguments, onStdoutLine: { _ in }, onStderrLine: { _ in }
        )
        guard status == 0 else { return nil }
        if let data = try? Data(contentsOf: output) { return data }
        guard let ffprobe, let info = try? await FFprobe.info(binary: ffprobe, file: url),
              let duration = info.duration, duration > 0, seconds >= duration,
              let step = MediaEditArguments.snapshot(url.path, format: "mp4", at: seconds, duration: duration)
        else { return nil }
        let tailStatus = await ProcessRunner.run(
            executable: ffmpeg,
            arguments: ["-hide_banner", "-nostdin", "-loglevel", "error"] + step.arguments
                + ["-vf", scale, output.path],
            onStdoutLine: { _ in }, onStderrLine: { _ in }
        )
        return tailStatus == 0 ? try? Data(contentsOf: output) : nil
    }

    public func adjusted(_ thumbnail: Data, with adjustments: ImageAdjustments) async -> Data? {
        try? await BlockingWork.run { () throws(JobError) -> Data in
            guard let source = CGImageSourceCreateWithData(thumbnail as CFData, nil),
                  let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { throw .failed }
            return try PNGWriter.data(try ImageAdjuster.apply(adjustments, to: image))
        }
    }

    public func pageThumbnails(of url: URL) async -> [Data] {
        (try? await BlockingWork.run { () throws(JobError) -> [Data] in
            let document = try PDFKitEngine.open(url)
            var thumbnails: [Data] = []
            var bytes = 0
            for index in 0..<document.pageCount {
                if BlockingWork.isCancelled { throw .cancelled }
                guard let page = document.page(at: index) else { throw .failed }
                let bounds = page.bounds(for: .mediaBox)
                let dpi = 72 * Self.pageThumbnailLongEdge / max(bounds.width, bounds.height, 1)
                let data = try PNGWriter.data(try PDFPageImageExporter.render(page, dpi: dpi))
                bytes += data.count
                guard bytes <= 32 * 1024 * 1024 else { throw .unsupported }
                thumbnails.append(data)
            }
            return thumbnails
        }) ?? []
    }

    private static func imagePreview(_ url: URL) throws(JobError) -> ToolPreview {
        let decoded = try ImageDecoding.decodeUpright(url)
        let thumbnail = ImageScaling.fit(decoded.image, longEdge: thumbnailLongEdge) ?? decoded.image
        return ToolPreview(width: decoded.image.width, height: decoded.image.height, duration: nil, pageCount: nil,
                           thumbnail: try PNGWriter.data(thumbnail))
    }

    private static func pdfPreview(_ url: URL) throws(JobError) -> ToolPreview {
        let document = try PDFKitEngine.open(url)
        let first = try document.page(at: 0).map { page throws(JobError) in
            try PDFPageImageExporter.render(page, dpi: 72)
        }
        return ToolPreview(width: first?.width, height: first?.height, duration: nil, pageCount: document.pageCount,
                           thumbnail: try first.map { image throws(JobError) in try PNGWriter.data(image) })
    }
}
