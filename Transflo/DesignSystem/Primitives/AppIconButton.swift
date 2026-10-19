import SwiftUI

/// A borderless symbol button; `label` names it for VoiceOver and the hover tooltip.
struct AppIconButton: View {
    @Environment(Localizer.self) private var localizer
    let symbol: AppSymbol
    let label: L10nKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            AppIcon(symbol: symbol, accessibilityLabel: label)
        }
        .buttonStyle(.borderless)
        .help(localizer.string(label))
    }
}
