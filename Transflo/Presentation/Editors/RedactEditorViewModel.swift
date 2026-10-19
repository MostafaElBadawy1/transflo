import Foundation
import Observation
import TransfloDomain

/// Redact: black boxes dragged over the image (or a PDF's first page).
@Observable
final class RedactEditorViewModel: ToolEditorModel {
    /// Smallest box side (unit coordinates) that counts as a deliberate box.
    static let minimumSide = 0.01

    private(set) var preview: ToolPreview = .empty
    private(set) var boxes: [NormalizedRect] = []
    private(set) var draft: NormalizedRect?
    @ObservationIgnored private var anchor: UnitPoint?
    @ObservationIgnored private var isLargeEnough = false

    @ObservationIgnored private let item: URL
    @ObservationIgnored private let format: FormatDescriptor?
    @ObservationIgnored private let previews: any ToolPreviewProviding

    init(item: URL, format: FormatDescriptor?, previews: any ToolPreviewProviding) {
        self.item = item
        self.format = format
        self.previews = previews
    }

    var isPDF: Bool { format?.id.rawValue == "pdf" }

    /// Finished boxes plus the one being dragged.
    var allBoxes: [NormalizedRect] { draft.map { boxes + [$0] } ?? boxes }

    var settings: ToolSettings? {
        guard preview.thumbnail != nil, !boxes.isEmpty else { return nil }
        return .redact(boxes)
    }

    func load() async {
        preview = await previews.preview(of: item, format: format)
    }

    func begin(at point: UnitPoint) {
        anchor = point
        move(to: point)
    }

    func move(to point: UnitPoint) {
        guard let anchor else { return }
        let width = abs(point.x - anchor.x)
        let height = abs(point.y - anchor.y)
        isLargeEnough = width >= Self.minimumSide && height >= Self.minimumSide
        draft = NormalizedRect(x: min(anchor.x, point.x), y: min(anchor.y, point.y), width: width, height: height)
    }

    /// Keeps the box unless it is too thin to mean anything.
    func end() {
        defer {
            draft = nil
            anchor = nil
        }
        guard let draft, isLargeEnough else { return }
        boxes.append(draft)
    }

    func undo() {
        _ = boxes.popLast()
    }

    func clear() {
        boxes.removeAll()
    }
}
