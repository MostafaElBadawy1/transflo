import SwiftUI

/// Redact editor: drag black boxes over what should disappear.
struct RedactEditorView: View {
    let model: RedactEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppMarkupBoard(thumbnail: model.preview.thumbnail, aspectRatio: PreviewAspect.ratio(model.preview),
                           redactions: model.allBoxes, onBegin: model.begin, onMove: model.move, onEnd: model.end)
            MarkupFooter(hint: model.isPDF ? .editorFirstPageHint : .editorRedactHint,
                         canUndo: !model.boxes.isEmpty, onUndo: model.undo, onClear: model.clear)
        }
    }
}
