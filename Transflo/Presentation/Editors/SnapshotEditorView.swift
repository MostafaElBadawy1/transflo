import SwiftUI

/// Snapshot editor: scrub to a moment and see that frame.
struct SnapshotEditorView: View {
    @Bindable var model: SnapshotEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppPreviewImage(data: model.frame).frame(height: AppDimensions.Editor.previewHeight)
            AppSlider(label: .editorFrameAt, value: $model.time, range: 0...max(model.duration, 0.1),
                      valueText: TimeLabel.text(model.time))
        }
        .task(id: model.time) {
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
            await model.refreshFrame()
        }
    }
}
