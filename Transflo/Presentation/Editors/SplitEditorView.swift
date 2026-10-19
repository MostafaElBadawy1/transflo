import SwiftUI

/// Split editor: number of equal parts for media, pages per file for PDFs.
struct SplitEditorView: View {
    @Bindable var model: SplitEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            if model.isPDF {
                AppNumberField(label: .editorPagesPerFile, value: $model.pagesPerFile, range: model.pageRange)
            } else {
                AppNumberField(label: .editorParts, value: $model.parts, range: SplitEditorViewModel.partRange)
            }
        }
    }
}
