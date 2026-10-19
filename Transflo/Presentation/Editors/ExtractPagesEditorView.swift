import SwiftUI

/// Extract editor: click the pages to keep in the new PDF.
struct ExtractPagesEditorView: View {
    let model: ExtractPagesEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppPageGrid(thumbnails: model.thumbnails, isSelected: model.isSelected, onToggle: model.toggle)
            HStack(spacing: AppDimensions.Spacing.small) {
                AppText(.editorPagesSelected, arguments: [String(model.selected.count), String(model.pageCount)],
                        style: .caption, color: .secondary)
                Spacer()
                AppButton(key: .editorSelectAll, variant: .tertiary) { model.selectAll() }
                AppButton(key: .editorSelectNone, variant: .tertiary) { model.selectNone() }
            }
        }
    }
}
