import SwiftUI
import TransfloDomain

/// Rename editor: the pattern, token shortcuts, the first number and a live preview.
struct RenameEditorView: View {
    @Bindable var model: RenameEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppTextField(label: .editorPattern, text: $model.pattern)
            HStack(spacing: AppDimensions.Spacing.small) {
                AppButton(key: .editorInsertName, variant: .tertiary) { model.insert(RenamePattern.nameToken) }
                AppButton(key: .editorInsertNumber, variant: .tertiary) { model.insert(RenamePattern.numberToken) }
                Spacer()
            }
            AppNumberField(label: .editorStartAt, value: $model.start, range: RenameEditorViewModel.startRange)
            AppText(.editorRenameHint, style: .caption, color: .secondary)
            SettingsDivider()
            ScrollView {
                VStack(alignment: .leading, spacing: AppDimensions.Spacing.xSmall) {
                    ForEach(model.rows) { row in
                        HStack(spacing: AppDimensions.Spacing.small) {
                            AppText(verbatim: row.old, color: .secondary)
                            AppIcon(symbol: .arrowForward, size: AppDimensions.IconSize.small)
                            AppText(verbatim: row.new)
                        }
                    }
                    if model.hiddenCount > 0 {
                        AppText(.editorRenameMore, arguments: [String(model.hiddenCount)],
                                style: .caption, color: .secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: AppDimensions.Editor.renamePreviewHeight)
        }
    }
}
