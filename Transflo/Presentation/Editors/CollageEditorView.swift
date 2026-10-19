import SwiftUI

/// Collage editor: grid preview, columns, gap and background.
struct CollageEditorView: View {
    @Bindable var model: CollageEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppCollagePreview(thumbnails: model.thumbnails, columns: model.columns,
                              spacing: CGFloat(model.spacing) / Self.previewScale,
                              backdrop: AppMarkupPalette.color(model.background))
            AppNumberField(label: .editorColumns, value: $model.columns, range: model.columnRange)
            AppNumberField(label: .editorSpacing, value: $model.spacing, range: CollageEditorViewModel.spacingRange)
            SettingsRow(label: .editorBackground) { AppColorSwatches(selection: $model.background) }
        }
    }

    /// The preview is far smaller than the output, so the gap is drawn scaled down.
    private static let previewScale: CGFloat = 4
}
