import SwiftUI

/// Resize editor: preview, width and height fields, proportion lock and quick sizes.
struct ResizeEditorView: View {
    @Bindable var model: ResizeEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppPreviewImage(data: model.preview.thumbnail).frame(height: AppDimensions.Editor.previewHeight)
            if let width = model.preview.width, let height = model.preview.height {
                AppText(.editorOriginalSize, arguments: [String(width), String(height)],
                        style: .caption, color: .secondary)
            }
            AppNumberField(label: .editorWidth, value: widthBinding, range: ResizeEditorViewModel.sizeRange)
            AppNumberField(label: .editorHeight, value: heightBinding, range: ResizeEditorViewModel.sizeRange)
            SettingsRow(label: .editorKeepProportions) {
                AppToggle(key: .editorKeepProportions, isOn: $model.keepsProportions)
            }
            HStack(spacing: AppDimensions.Spacing.small) {
                AppButton(key: .editorHalfSize) { model.scale(50) }
                AppButton(key: .editorQuarterSize) { model.scale(25) }
            }
        }
    }

    private var widthBinding: Binding<Int> {
        Binding(get: { model.width }, set: { model.setWidth($0) })
    }

    private var heightBinding: Binding<Int> {
        Binding(get: { model.height }, set: { model.setHeight($0) })
    }
}
