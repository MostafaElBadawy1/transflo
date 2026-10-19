import Foundation
import Observation
import TransfloDomain

/// Trim: keep the part between two times.
@Observable
final class TrimEditorViewModel: ToolEditorModel {
    static let minimumLength = 0.1

    private(set) var preview: ToolPreview = .empty
    var start = 0.0
    var end = 0.0

    @ObservationIgnored private let item: URL
    @ObservationIgnored private let format: FormatDescriptor?
    @ObservationIgnored private let previews: any ToolPreviewProviding

    init(item: URL, format: FormatDescriptor?, previews: any ToolPreviewProviding) {
        self.item = item
        self.format = format
        self.previews = previews
    }

    var duration: Double { preview.duration ?? 0 }

    var settings: ToolSettings? {
        guard duration > 0, end - start >= Self.minimumLength, start > 0 || end < duration else { return nil }
        return .trim(start: start, end: end)
    }

    func load() async {
        preview = await previews.preview(of: item, format: format)
        start = 0
        end = duration
    }
}
