import Foundation
import PDFKit
import TransfloDomain

/// PDF input: text (TXT, Markdown, DOCX, EPUB), page images (JPG, PNG at 300 DPI),
/// tables (XLSX, from text layout) and slides (PPTX, one page image per slide).
///
/// A one-page PDF becomes one image beside it; longer ones become a `name (PNG)` folder of
/// numbered pages. Password-protected PDFs are refused.
public struct PDFKitEngine: ConversionEngine {
    public let id = EngineIDs.pdfKit
    static let textTargets: Set<String> = ["txt", "md", "docx", "epub"]
    static let imageTargets: Set<String> = ["jpg", "png"]
    static let otherTargets: Set<String> = ["xlsx", "pptx"]
    /// Slides are rendered at 2× screen resolution: sharp on Retina, modest in size.
    static let slideDPI: CGFloat = 144

    private let naming: NameOutputFileUseCase

    public init(naming: NameOutputFileUseCase) {
        self.naming = naming
    }

    public func canConvert(from source: FormatDescriptor, to target: FormatDescriptor) -> Bool {
        source.id.rawValue == "pdf"
            && [Self.textTargets, Self.imageTargets, Self.otherTargets].contains { $0.contains(target.id.rawValue) }
    }

    public func convert(
        _ request: ConversionRequest,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws(JobError) -> [URL] {
        try await BlockingWork.runCancellable { [naming] isCancelled throws(JobError) -> [URL] in
            let document = try Self.open(request.source)
            let target = request.targetFormat.id.rawValue
            if Self.imageTargets.contains(target) {
                return try PDFPageImageExporter(naming: naming).export(
                    document, request: request, isCancelled: isCancelled, progress: progress
                )
            }
            if target == "xlsx" {
                let workbook = PDFTableExtractor.workbook(from: document)
                guard !workbook.isEmpty else { throw .nothingFound }
                try XLSXWriter.write(workbook, to: request.destination)
                progress(1)
                return [request.destination]
            }
            if target == "pptx" {
                try Self.writeSlides(document, to: request.destination, isCancelled: isCancelled, progress: progress)
                return [request.destination]
            }
            let title = request.source.deletingPathExtension().lastPathComponent
            let text = PDFTextExtractor.attributedText(of: document)
            guard !text.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw .nothingFound }
            progress(0.6)
            let loaded = LoadedDocument(text: text, blocks: nil)
            try DocumentWriter.write(loaded, format: target, title: title, to: request.destination)
            progress(1)
            return [request.destination]
        }
    }

    private static func writeSlides(
        _ document: PDFDocument,
        to url: URL,
        isCancelled: () -> Bool,
        progress: (Double) -> Void
    ) throws(JobError) {
        var slides: [Data] = []
        var aspect = 0.75
        var retainedBytes = 0
        for index in 0..<document.pageCount {
            if isCancelled() { throw .cancelled }
            guard let page = document.page(at: index) else { continue }
            let image = try PDFPageImageExporter.render(page, dpi: slideDPI)
            if index == 0 { aspect = Double(image.height) / Double(image.width) }
            let data = try PNGWriter.data(image)
            retainedBytes += data.count
            guard retainedBytes <= 128 * 1024 * 1024 else { throw .unsupported }
            slides.append(data)
            progress(Double(index + 1) / Double(document.pageCount) * 0.9)
        }
        try PPTXWriter.write(slides: slides, aspectRatio: aspect, to: url)
        progress(1)
    }

    static func open(_ url: URL) throws(JobError) -> PDFDocument {
        guard FileManager.default.fileExists(atPath: url.path) else { throw .sourceMissing }
        guard let document = PDFDocument(url: url), !document.isLocked, document.pageCount > 0 else { throw .failed }
        guard document.pageCount <= 2_000 else { throw .unsupported }
        return document
    }
}
