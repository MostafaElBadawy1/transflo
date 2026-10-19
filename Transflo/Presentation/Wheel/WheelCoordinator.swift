import Foundation
import TransfloDomain

/// Drives the wheel from drag events (and, in keyboard mode, from keys): opens, switches and closes
/// it, and schedules the chosen option.
final class WheelCoordinator: KeyboardWheelOpening {
    /// Keyboard mode opens the first of these wheels that has options for the selection.
    static let keyboardWheelOrder: [WheelKind] = [.convert, .tools, .actions]

    private let resolveOptions: ResolveWheelOptionsUseCase
    private let presenter: any WheelPresenting
    private let viewModel: WheelViewModel
    private let scheduler: any JobScheduling
    private let editor: any ToolEditing
    private let preparer: any ActionPreparing
    private let summaryProvider: (any DragSummaryProviding)?
    private var summary: DragSummary?
    private let dismissDelay: Duration

    private var items: [URL] = []
    private var openPoint: WheelPoint?
    private var pendingDismiss: Task<Void, Never>?
    private var listener: Task<Void, Never>?

    /// - Parameter dismissDelay: Grace period after mouse-up before closing, because the drop can
    ///   arrive just after the monitor sees the button release.
    init(
        resolveOptions: ResolveWheelOptionsUseCase,
        presenter: any WheelPresenting,
        viewModel: WheelViewModel,
        scheduler: any JobScheduling,
        editor: any ToolEditing,
        preparer: any ActionPreparing,
        dismissDelay: Duration = .milliseconds(300),
        summaryProvider: (any DragSummaryProviding)? = nil
    ) {
        self.resolveOptions = resolveOptions
        self.presenter = presenter
        self.viewModel = viewModel
        self.scheduler = scheduler
        self.editor = editor
        self.preparer = preparer
        self.dismissDelay = dismissDelay
        self.summaryProvider = summaryProvider
        presenter.onHover = { [weak viewModel] offset in viewModel?.updatePointer(offset) ?? false }
        presenter.onDrop = { [weak self] offset in self?.handleDrop(at: offset) ?? false }
        presenter.onClick = { [weak self] offset in self?.handleClick(at: offset) ?? false }
        presenter.onKey = { [weak self] command in self?.handleKey(command) }
        presenter.onPointer = { [weak viewModel] offset in viewModel?.highlightWedge(at: offset) }
    }

    /// Opens the wheel for `items` with keyboard focus at `point` (hotkey or Service).
    /// Returns `false` when no wheel has options for them.
    @discardableResult
    func openForKeyboard(items: [URL], at point: WheelPoint) -> Bool {
        close()
        guard let kind = Self.keyboardWheelOrder.first(where: {
            !resolveOptions.execute(wheel: $0, items: items).isEmpty
        }) else { return false }
        self.items = items
        summary = summaryProvider?.summary(for: items)
        viewModel.show(kind, options: resolveOptions.execute(wheel: kind, items: items), summary: summary)
        presenter.showInteractive(at: point)
        openPoint = point
        return true
    }

    func handleKey(_ command: WheelKeyCommand) {
        guard let point = openPoint else { return }
        switch command {
        case .step(let clockwise):
            viewModel.stepHighlight(clockwise: clockwise)
        case .confirm:
            guard let option = viewModel.activateHighlighted() else { return }
            let items = self.items
            close()
            dispatch(option, items: items, near: point)
        case .cancel:
            close()
        case .modifier(let key):
            if let kind = viewModel.wheel(for: key) { open(kind, at: point) }
        }
    }

    /// Consumes drag events until the stream finishes.
    func start(listeningTo events: AsyncStream<DragEvent>) {
        listener?.cancel()
        listener = Task { [weak self] in
            for await event in events {
                self?.handle(event)
            }
        }
    }

    func handle(_ event: DragEvent) {
        switch event {
        case .began(let items):
            close()
            self.items = items
            summary = summaryProvider?.summary(for: items)
        case let .wheelRequested(kind, point):
            open(kind, at: point)
        case .ended:
            scheduleDismiss()
        }
    }

    /// Clicks page immediately on More; file drops still require an operation wedge.
    @discardableResult
    func handleClick(at offset: WheelPoint) -> Bool {
        guard openPoint != nil else { return false }
        if viewModel.isMore(at: offset) {
            viewModel.turnPage()
            return true
        }
        return handleDrop(at: offset)
    }

    /// A drop on a paging control is not a file operation.
    @discardableResult
    func handleDrop(at offset: WheelPoint) -> Bool {
        guard let point = openPoint, let option = viewModel.option(at: offset) else {
            close()
            return false
        }
        let items = self.items
        close()
        dispatch(option, items: items, near: point)
        return true
    }

    /// Schedules `option`, first asking an editor or a preparer for settings when it needs them.
    private func dispatch(_ option: WheelOption, items: [URL], near point: WheelPoint) {
        let schedule: (ToolSettings) -> Void = { [scheduler] settings in
            scheduler.schedule(WheelOption(option.kind, settings: settings), items: items, near: point)
        }
        switch option.kind {
        case .tool(let tool) where option.settings == nil && editor.canEdit(tool):
            // Interactive tools open their editor; Apply schedules the job with the chosen settings.
            editor.edit(tool, items: items, onApply: schedule)
        case .action(let action) where option.settings == nil && preparer.needsPreparation(action):
            preparer.prepare(action, items: items, near: point, onReady: schedule)
        default:
            scheduler.schedule(option, items: items, near: point)
        }
    }

    private func open(_ kind: WheelKind, at point: WheelPoint) {
        let options = resolveOptions.execute(wheel: kind, items: items)
        guard !options.isEmpty else { return }
        pendingDismiss?.cancel()
        viewModel.show(kind, options: options, summary: summary)
        if openPoint == nil {
            presenter.show(at: point)
            openPoint = point
        }
    }

    private func scheduleDismiss() {
        guard openPoint != nil else { return }
        pendingDismiss?.cancel()
        pendingDismiss = Task { [weak self, dismissDelay] in
            try? await Task.sleep(for: dismissDelay)
            guard !Task.isCancelled else { return }
            self?.close()
        }
    }

    private func close() {
        pendingDismiss?.cancel()
        pendingDismiss = nil
        guard openPoint != nil else { return }
        presenter.hide()
        viewModel.reset()
        openPoint = nil
    }
}
