import Foundation
import Observation
import TransfloDomain

/// Adjust: exposure, contrast and saturation with a live preview.
@Observable
final class AdjustEditorViewModel: ToolEditorModel {
    private(set) var preview: ToolPreview = .empty
    private(set) var adjustedThumbnail: Data?
    var exposure = 0.0
    var contrast = 1.0
    var saturation = 1.0

    @ObservationIgnored private let item: URL
    @ObservationIgnored private let format: FormatDescriptor?
    @ObservationIgnored private let previews: any ToolPreviewProviding

    init(item: URL, format: FormatDescriptor?, previews: any ToolPreviewProviding) {
        self.item = item
        self.format = format
        self.previews = previews
    }

    var adjustments: ImageAdjustments {
        ImageAdjustments(exposure: exposure, contrast: contrast, saturation: saturation)
    }

    var settings: ToolSettings? {
        adjustments.isNeutral ? nil : .adjust(adjustments)
    }

    func load() async {
        preview = await previews.preview(of: item, format: format)
        adjustedThumbnail = preview.thumbnail
    }

    /// Re-renders the preview for the current sliders (the view debounces calls).
    func refreshPreview() async {
        guard let thumbnail = preview.thumbnail else { return }
        let requested = adjustments
        let rendered = await previews.adjusted(thumbnail, with: requested)
        if requested == adjustments { adjustedThumbnail = rendered ?? thumbnail }
    }

    func reset() {
        exposure = 0
        contrast = 1
        saturation = 1
    }
}
