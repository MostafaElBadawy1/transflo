import SwiftUI

/// Annotate editor: draw on the preview, pick the mark, color and thickness.
struct AnnotateEditorView: View {
    @Bindable var model: AnnotateEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppMarkupBoard(thumbnail: model.preview.thumbnail, aspectRatio: PreviewAspect.ratio(model.preview),
                           annotations: model.marks, onBegin: model.begin, onMove: model.move, onEnd: model.end)
            SettingsRow(label: .editorMarkupTool) {
                AppSegmentedPicker(key: .editorMarkupTool, selection: $model.tool, options: Self.tools)
            }
            if model.tool == .text {
                AppTextField(label: .editorTextContent, text: $model.text)
            }
            SettingsRow(label: .editorColor) { AppColorSwatches(selection: $model.color) }
            SettingsRow(label: .editorWeight) {
                AppSegmentedPicker(key: .editorWeight, selection: $model.weight, options: Self.weights)
            }
            MarkupFooter(hint: model.isPDF ? .editorFirstPageHint : .editorAnnotateHint,
                         canUndo: !model.annotations.isEmpty, onUndo: model.undo, onClear: model.clear)
        }
    }

    private static let tools: [AppSegmentedPicker<MarkupTool>.Option] = [
        .init(value: .box, label: .markupBox), .init(value: .arrow, label: .markupArrow),
        .init(value: .pen, label: .markupPen), .init(value: .text, label: .markupText)
    ]

    private static let weights: [AppSegmentedPicker<MarkupWeight>.Option] = [
        .init(value: .thin, label: .weightThin), .init(value: .medium, label: .weightMedium),
        .init(value: .thick, label: .weightThick)
    ]
}
