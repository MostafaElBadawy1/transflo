import Foundation
import Observation
import TransfloDomain

/// Split: media into N equal parts, or a PDF into files of N pages.
@Observable
final class SplitEditorViewModel: ToolEditorModel {
    static let partRange = 2...20

    private(set) var preview: ToolPreview = .empty
    var parts = 2
    var pagesPerFile = 1

    @ObservationIgnored private let item: URL
    @ObservationIgnored private let format: FormatDescriptor?
    @ObservationIgnored private let previews: any ToolPreviewProviding

    init(item: URL, format: FormatDescriptor?, previews: any ToolPreviewProviding) {
        self.item = item
        self.format = format
        self.previews = previews
    }

    var isPDF: Bool { format?.id.rawValue == "pdf" }

    /// Allowed pages per file: from 1 up to one less than the document.
    var pageRange: ClosedRange<Int> { 1...max(1, (preview.pageCount ?? 2) - 1) }

    var settings: ToolSettings? {
        if isPDF {
            guard let pages = preview.pageCount, pages > 1, pageRange.contains(pagesPerFile) else { return nil }
            return .splitPages(every: pagesPerFile)
        }
        guard let duration = preview.duration, duration > 0, Self.partRange.contains(parts) else { return nil }
        return .split(points: (1..<parts).map { duration * Double($0) / Double(parts) })
    }

    func load() async {
        preview = await previews.preview(of: item, format: format)
    }
}
