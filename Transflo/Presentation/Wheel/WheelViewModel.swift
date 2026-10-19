import Foundation
import Observation
import TransfloDomain

/// State and intents for the open wheel: which options it shows, which page of them is visible,
/// and which wedge is under the pointer.
///
/// Up to 12 options fit on one ring, which grows with the option count (`WheelSizing`). Longer
/// lists show 11 per page plus a More wedge; resting the pointer on More for `dwellDelay` turns
/// to the next page (wrapping around).
@Observable
final class WheelViewModel {
    /// Everything the wheel renders.
    struct State: Equatable {
        var kind: WheelKind?
        var options: [WheelOption] = []
        var summary: DragSummary?
        var page = 0
        var slots: [WheelSlot] = []
        var highlightedIndex: Int?
        var geometry = WheelGeometry(wedgeCount: 0, innerRadius: 0, outerRadius: 0, isRightToLeft: false)
    }

    static let wedgesPerRing = 12

    private(set) var state = State()

    @ObservationIgnored private var bindings: WheelKeyBindings
    @ObservationIgnored private let layout: any LayoutDirectionProviding
    @ObservationIgnored private let sizingProvider: (() -> WheelSizing)?
    @ObservationIgnored private let byteFormatter: (any ByteSizeFormatting)?
    @ObservationIgnored private let localizer: Localizer?
    @ObservationIgnored private let sizing: WheelSizing
    @ObservationIgnored private let dwellDelay: Duration
    @ObservationIgnored private var dwellTask: Task<Void, Never>?

    init(
        bindings: WheelKeyBindings,
        layout: any LayoutDirectionProviding,
        sizing: WheelSizing = .standard,
        dwellDelay: Duration = .milliseconds(400),
        sizingProvider: (() -> WheelSizing)? = nil,
        byteFormatter: (any ByteSizeFormatting)? = nil,
        localizer: Localizer? = nil
    ) {
        self.byteFormatter = byteFormatter
        self.localizer = localizer
        self.bindings = bindings
        self.layout = layout
        self.sizing = sizing
        self.sizingProvider = sizingProvider
        self.dwellDelay = dwellDelay
    }

    /// The modifier glyph shown in the hub, e.g. "⇧" for Convert.
    var hubGlyph: String {
        guard let kind = state.kind, let key = bindings.key(for: kind) else { return "" }
        return WheelPresentation.glyph(for: key)
    }

    /// Useful selection facts, replaced by the hovered option inside the hub component.
    var hubDetail: String? {
        guard let summary = state.summary, summary.itemCount > 0,
              let total = summary.totalBytes, let byteFormatter, let localizer else { return nil }
        let size = byteFormatter.string(bytes: total, locale: localizer.locale)
        guard summary.itemCount > 1 else { return size }
        let count = summary.itemCount.formatted(.number.locale(localizer.locale))
        return localizer.string(.wheelSelectionSummary, arguments: [count, size])
    }

    var hubTitle: L10nKey {
        state.kind.map(WheelPresentation.title(for:)) ?? .wheelConvert
    }

    var pageCount: Int {
        let count = state.options.count
        guard count > Self.wedgesPerRing else { return 1 }
        let perPage = Self.wedgesPerRing - 1
        return (count + perPage - 1) / perPage
    }

    /// Shows `options` for `kind`, laid out for the current reading direction.
    func show(_ kind: WheelKind, options: [WheelOption], summary: DragSummary? = nil) {
        dwellTask?.cancel()
        state = State(kind: kind, options: options, summary: summary)
        layOut(page: 0)
    }

    /// Highlights the wedge under `offset` (from the wheel center, y up); `nil` clears it.
    /// Resting on More starts the page-turn timer.
    /// - Returns: Whether the pointer is over a droppable option.
    @discardableResult
    func updatePointer(_ offset: WheelPoint?) -> Bool {
        let index = offset.flatMap(state.geometry.wedgeIndex(at:))
        if index != state.highlightedIndex {
            state.highlightedIndex = index
            dwellTask?.cancel()
            if let index, state.slots[index] == .more { startDwell() }
        }
        guard let index else { return false }
        return state.slots[index] != .more
    }

    /// Whether the pointer is on the paging control.
    func isMore(at offset: WheelPoint) -> Bool {
        guard let index = state.geometry.wedgeIndex(at: offset) else { return false }
        return state.slots[index] == .more
    }

    /// The option under `offset`, or `nil` over the hub, More, or outside the ring.
    func option(at offset: WheelPoint) -> WheelOption? {
        guard let index = state.geometry.wedgeIndex(at: offset), case .option(let option) = state.slots[index] else {
            return nil
        }
        return option
    }

    /// Uses new key bindings from now on (the hub glyph and modifier taps in keyboard mode).
    func update(bindings: WheelKeyBindings) {
        self.bindings = bindings
    }

    /// Keyboard mode: highlights the wedge under the pointer. Over the hub or outside the ring
    /// the arrow-key highlight stays, and More never auto-turns.
    func highlightWedge(at offset: WheelPoint) {
        guard let index = state.geometry.wedgeIndex(at: offset) else { return }
        dwellTask?.cancel()
        state.highlightedIndex = index
    }

    /// The wheel bound to `key`, if any.
    func wheel(for key: ModifierKey) -> WheelKind? {
        bindings.wheel(for: key)
    }

    /// Moves the highlight one wedge as seen on screen (right-to-left wheels run counter-clockwise),
    /// wrapping around. Keyboard highlighting never auto-turns pages.
    func stepHighlight(clockwise: Bool) {
        guard !state.slots.isEmpty else { return }
        let count = state.slots.count
        dwellTask?.cancel()
        let step = clockwise == state.geometry.isRightToLeft ? -1 : 1
        guard let current = state.highlightedIndex else {
            // The first press lands on the top wedge going clockwise, or on its neighbor going back.
            state.highlightedIndex = clockwise ? 0 : (step + count) % count
            return
        }
        state.highlightedIndex = (current + step + count) % count
    }

    /// The highlighted option, or `nil` when nothing is highlighted. On More this turns the page
    /// and keeps More highlighted, so pressing again keeps paging.
    func activateHighlighted() -> WheelOption? {
        guard let index = state.highlightedIndex, state.slots.indices.contains(index) else { return nil }
        guard case .option(let option) = state.slots[index] else {
            turnPage()
            state.highlightedIndex = state.slots.firstIndex(of: .more)
            return nil
        }
        return option
    }

    /// Shows the next page of options (wrapping).
    func turnPage() {
        dwellTask?.cancel()
        guard pageCount > 1 else { return }
        layOut(page: (state.page + 1) % pageCount)
    }

    /// Clears the wheel after it closes.
    func reset() {
        dwellTask?.cancel()
        state = State()
    }

    private func startDwell() {
        dwellTask = Task { [weak self, dwellDelay] in
            try? await Task.sleep(for: dwellDelay)
            guard !Task.isCancelled else { return }
            self?.turnPage()
        }
    }

    private func layOut(page: Int) {
        let options = state.options
        let slots: [WheelSlot]
        if options.count <= Self.wedgesPerRing {
            slots = options.map(WheelSlot.option)
        } else {
            let perPage = Self.wedgesPerRing - 1
            slots = options.dropFirst(page * perPage).prefix(perPage).map(WheelSlot.option) + [.more]
        }
        state.page = page
        state.slots = slots
        state.highlightedIndex = nil
        let sizing = sizingProvider?() ?? sizing
        state.geometry = WheelGeometry(
            wedgeCount: slots.count,
            innerRadius: sizing.innerRadius,
            outerRadius: sizing.outerRadius(forWedgeCount: slots.count),
            isRightToLeft: layout.isRightToLeft
        )
    }
}
