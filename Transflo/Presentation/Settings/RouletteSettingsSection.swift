import SwiftUI
import TransfloDomain

/// Russian Roulette mode and its separate mute. Cosmetic only: jobs run the same either way.
struct RouletteSettingsSection: View {
    let viewModel: CustomizationViewModel

    var body: some View {
        SettingsSection(title: .settingsRouletteSection) {
            SettingsRow(label: .settingsRouletteMode) {
                AppToggle(key: .settingsRouletteMode, isOn: binding(\.rouletteMode))
            }
            SettingsFootnote(message: .settingsRouletteModeHint)
            SettingsDivider()
            SettingsRow(label: .settingsRouletteMute) {
                AppToggle(key: .settingsRouletteMute, isOn: binding(\.rouletteSoundsMuted))
                    .disabled(!viewModel.preferences.rouletteMode)
            }
        }
    }

    private func binding(_ keyPath: WritableKeyPath<InterfaceCustomization, Bool>) -> Binding<Bool> {
        Binding(get: { viewModel.preferences[keyPath: keyPath] }, set: { value in
            viewModel.update { $0[keyPath: keyPath] = value }
        })
    }
}
