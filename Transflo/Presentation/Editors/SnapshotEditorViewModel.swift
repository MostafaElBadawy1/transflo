import Foundation
import Observation
import TransfloDomain

/// Snapshot: pick a moment and save that frame as an image.
@Observable
final class SnapshotEditorViewModel: ToolEditorModel {
    private(set) var preview: ToolPreview = .empty
    private(set) var frame: Data?
    var time = 0.0

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
        duration > 0 ? .snapshot(at: min(max(time, 0), duration)) : nil
    }

    func load() async {
        preview = await previews.preview(of: item, format: format)
        frame = preview.thumbnail
    }

    /// Fetches the frame at `time` (the view debounces calls).
    func refreshFrame() async {
        let requested = time
        let image = await previews.frame(of: item, at: requested)
        if requested == time, let image { frame = image }
    }
}
