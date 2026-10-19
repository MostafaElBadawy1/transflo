import SwiftUI

/// Trim editor: a two-handle range over the clip's length.
struct TrimEditorView: View {
    @Bindable var model: TrimEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            if model.preview.thumbnail != nil {
                AppPreviewImage(data: model.preview.thumbnail).frame(height: AppDimensions.Editor.previewHeight)
            }
            AppRangeSlider(lower: $model.start, upper: $model.end, bounds: 0...max(model.duration, 0.1),
                           minimumSpan: TrimEditorViewModel.minimumLength)
            AppText(.editorRange, arguments: [
                TimeLabel.text(model.start), TimeLabel.text(model.end), TimeLabel.text(model.end - model.start)
            ], style: .caption, color: .secondary)
        }
    }
}
