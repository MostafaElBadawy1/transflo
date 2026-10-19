import SwiftUI

/// The frame every tool editor shares: a title, the editor's content, and Cancel / Apply.
struct AppEditorScaffold<Content: View>: View {
    let title: L10nKey
    let canApply: Bool
    let onCancel: () -> Void
    let onApply: () -> Void
    var actionKey: L10nKey = .editorApply
    var width = AppDimensions.Editor.width
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.large) {
            AppText(title, style: .title)
            content()
            HStack(spacing: AppDimensions.Spacing.small) {
                Spacer()
                AppButton(key: .editorCancel, variant: .secondary, action: onCancel)
                AppButton(key: actionKey, variant: .primary, isEnabled: canApply, action: onApply)
            }
        }
        .padding(AppDimensions.Spacing.xLarge)
        .frame(width: width)
        .background(AppWindowBackdrop().ignoresSafeArea())
    }
}
