import SwiftUI

/// A localized push button. `primary` uses the accent and answers Return; `secondary` answers Esc;
/// `tertiary` answers only its own `shortcut`.
struct AppButton: View {
    enum Variant {
        case primary
        case secondary
        /// An in-editor action: bordered, with no Return/Esc binding (optionally its own `shortcut`).
        case tertiary
    }

    @Environment(Localizer.self) private var localizer
    let key: L10nKey
    var variant: Variant = .secondary
    var isEnabled = true
    var shortcut: KeyboardShortcut?
    let action: () -> Void

    var body: some View {
        switch variant {
        case .primary:
            Button(localizer.string(key), action: action)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accent)
                .keyboardShortcut(.defaultAction)
                .disabled(!isEnabled)
        case .secondary:
            Button(localizer.string(key), action: action)
                .buttonStyle(.bordered)
                .keyboardShortcut(.cancelAction)
                .disabled(!isEnabled)
        case .tertiary:
            Button(localizer.string(key), action: action)
                .buttonStyle(.bordered)
                .keyboardShortcut(shortcut)
                .disabled(!isEnabled)
        }
    }
}
