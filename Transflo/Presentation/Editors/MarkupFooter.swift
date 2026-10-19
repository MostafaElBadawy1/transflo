import SwiftUI

/// The hint plus Undo (⌘Z) and Clear under the annotate and redact boards.
struct MarkupFooter: View {
    let hint: L10nKey
    let canUndo: Bool
    let onUndo: () -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: AppDimensions.Spacing.small) {
            AppText(hint, style: .caption, color: .secondary)
            Spacer()
            AppButton(key: .editorUndo, variant: .tertiary, isEnabled: canUndo,
                      shortcut: KeyboardShortcut("z", modifiers: .command), action: onUndo)
            AppButton(key: .editorClear, variant: .tertiary, isEnabled: canUndo, action: onClear)
        }
    }
}
