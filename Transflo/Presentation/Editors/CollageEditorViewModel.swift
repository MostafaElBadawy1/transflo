import Foundation
import Observation
import TransfloDomain

/// Collage: the dropped images in a grid with a gap and a background color.
@Observable
final class CollageEditorViewModel: ToolEditorModel {
    static let spacingRange = 0...200
    /// Thumbnails shown in the preview; the collage itself uses every image.
    static let previewLimit = 24

    private(set) var thumbnails: [Data?] = []
    var columns: Int
    var spacing = 16
    var background = AppMarkupPalette.defaultBackground

    @ObservationIgnored private let items: [URL]
    @ObservationIgnored private let formats: [FormatDescriptor?]
    @ObservationIgnored private let previews: any ToolPreviewProviding

    init(items: [URL], formats: [FormatDescriptor?], previews: any ToolPreviewProviding) {
        self.items = items
        self.formats = formats
        self.previews = previews
        columns = Self.defaultColumns(for: items.count)
    }

    var imageCount: Int { items.count }
    var columnRange: ClosedRange<Int> { 1...max(1, items.count) }

    var settings: ToolSettings? {
        guard items.count >= 2, columnRange.contains(columns), Self.spacingRange.contains(spacing) else { return nil }
        return .collage(columns: columns, spacing: spacing, background: background)
    }

    func load() async {
        var loaded: [Data?] = []
        for (item, format) in zip(items, formats).prefix(Self.previewLimit) {
            loaded.append(await previews.preview(of: item, format: format).thumbnail)
        }
        thumbnails = loaded
    }

    /// The squarest grid: 2 → 2, 4 → 2, 5 → 3, 10 → 4.
    static func defaultColumns(for count: Int) -> Int {
        max(1, Int(Double(count).squareRoot().rounded(.up)))
    }
}
