import SwiftUI

/// Instant compression preferences stay out of the per-drop path.
struct ToolPreferencesView: View {
    let model: ToolPreferencesViewModel

    var body: some View {
        SettingsSection(title: .settingsCompression) {
            AppChipGroup(key: .settingsCompression, selection: choice, options: Self.options)
            SettingsFootnote(message: description)
            if model.choice == .target {
                AppDecimalNumberField(label: .settingsTargetSize, unit: .unitMegabytes,
                                      value: Binding(get: { model.targetMegabytes },
                                                     set: { model.setTargetMegabytes($0) }))
            }
        }
    }

    private var description: L10nKey {
        switch model.choice {
        case .light: .compressionLightHint
        case .medium: .compressionMediumHint
        case .strong: .compressionStrongHint
        case .target: .settingsTargetHint
        }
    }

    private var choice: Binding<CompressionChoice> {
        Binding(get: { model.choice }, set: { model.select($0) })
    }

    private static let options: [AppSegmentedPicker<CompressionChoice>.Option] = [
        .init(value: .light, label: .compressionLight), .init(value: .medium, label: .compressionMedium),
        .init(value: .strong, label: .compressionStrong), .init(value: .target, label: .compressionTarget)
    ]
}
