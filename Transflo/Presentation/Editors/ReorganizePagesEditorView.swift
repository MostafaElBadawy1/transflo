import SwiftUI

/// Reorganize editor: drag pages into order; remove the ones to leave out.
struct ReorganizePagesEditorView: View {
    let model: ReorganizePagesEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppText(.editorReorderHint, style: .caption, color: .secondary)
            AppReorderableList(items: model.order, onMove: model.move) { page in
                HStack(spacing: AppDimensions.Spacing.medium) {
                    AppPreviewImage(data: model.thumbnail(ofPage: page), backdrop: .clear)
                        .frame(width: AppDimensions.Editor.rowThumbnailSize,
                               height: AppDimensions.Editor.rowThumbnailSize)
                    AppText(.editorPage, arguments: [String(page + 1)])
                    Spacer()
                    AppIconButton(symbol: .remove, label: .editorRemove) { model.remove(page: page) }
                }
            }
            HStack {
                Spacer()
                AppButton(key: .editorReset, variant: .tertiary, isEnabled: model.settings != nil) { model.reset() }
            }
        }
    }
}
