import SwiftUI
import TransfloDomain

/// Hosts the right editor for a session inside the shared scaffold.
struct ToolEditorView: View {
    let tool: ToolKind
    let session: ToolEditorSession
    let onCancel: () -> Void
    let onApply: (ToolSettings) -> Void

    var body: some View {
        AppEditorScaffold(
            title: WheelPresentation.toolLabels[tool] ?? .wheelTools,
            canApply: session.model.settings != nil,
            onCancel: onCancel,
            onApply: { session.model.settings.map(onApply) },
            actionKey: tool == .addBackground ? .beautifySave : .editorApply,
            width: tool == .addBackground ? AppDimensions.Beautify.editorWidth : AppDimensions.Editor.width,
            content: { editor }
        )
        .task { await session.model.load() }
    }

    @ViewBuilder private var editor: some View {
        switch session {
        case .resize(let model): ResizeEditorView(model: model)
        case .crop(let model): CropEditorView(model: model)
        case .adjust(let model): AdjustEditorView(model: model)
        case .trim(let model): TrimEditorView(model: model)
        case .speed(let model): SpeedEditorView(model: model)
        case .split(let model): SplitEditorView(model: model)
        case .snapshot(let model): SnapshotEditorView(model: model)
        case .annotate(let model): AnnotateEditorView(model: model)
        case .redact(let model): RedactEditorView(model: model)
        case .background(let model): AddBackgroundEditorView(model: model)
        case .collage(let model): CollageEditorView(model: model)
        case .bleep(let model): BleepEditorView(model: model)
        case .reorganize(let model): ReorganizePagesEditorView(model: model)
        case .extract(let model): ExtractPagesEditorView(model: model)
        case .metadata(let model): MetadataEditorView(model: model)
        case .rename(let model): RenameEditorView(model: model)
        }
    }
}
