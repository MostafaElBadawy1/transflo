import SwiftUI

/// Edit metadata editor: title, author and comment fields.
struct MetadataEditorView: View {
    @Bindable var model: MetadataEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppText(verbatim: model.fileName, style: .caption, color: .secondary)
            AppTextField(label: .metadataTitle, text: $model.title)
            AppTextField(label: .metadataAuthor, text: $model.author)
            AppTextField(label: .metadataComment, text: $model.comment)
            AppText(.editorMetadataHint, style: .caption, color: .secondary)
        }
    }
}
