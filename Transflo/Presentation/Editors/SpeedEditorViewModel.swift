import Foundation
import Observation
import TransfloDomain

/// Change speed: 0.25× to 4×, with the resulting length shown.
@Observable
final class SpeedEditorViewModel: ToolEditorModel {
    private(set) var preview: ToolPreview = .empty
    var factor = 2.0

    @ObservationIgnored private let item: URL
    @ObservationIgnored private let format: FormatDescriptor?
    @ObservationIgnored private let previews: any ToolPreviewProviding

    init(item: URL, format: FormatDescriptor?, previews: any ToolPreviewProviding) {
        self.item = item
        self.format = format
        self.previews = previews
    }

    /// Length after the change, when known.
    var newDuration: Double? {
        preview.duration.map { $0 / factor }
    }

    var settings: ToolSettings? {
        let rounded = (factor * 100).rounded() / 100
        guard ToolSettings.speedRange.contains(rounded), abs(rounded - 1) > 0.001 else { return nil }
        return .changeSpeed(rounded)
    }

    func load() async {
        preview = await previews.preview(of: item, format: format)
    }
}
