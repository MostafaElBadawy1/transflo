import SwiftUI
import TransfloDomain

/// Visual preferences with a live wheel preview and a scoped reset.
struct CustomizationSettingsView: View {
    let settings: SettingsViewModel
    let viewModel: CustomizationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.xLarge) {
            SettingsSection(title: .settingsAppearance) {
                SettingsRow(label: .settingsAppearance) {
                    AppSegmentedPicker(key: .settingsAppearance, selection: appearance, options: Self.appearances,
                                       width: AppDimensions.Window.settingsControlWidth)
                }
                SettingsDivider()
                AppAccentPicker(selection: binding(\.accentHex))
            }
            SettingsSection(title: .settingsWheelStyle) {
                SettingsRow(label: .settingsWheelSize) {
                    AppSegmentedPicker(key: .settingsWheelSize, selection: binding(\.wheelSize), options: Self.sizes,
                                       width: AppDimensions.Window.settingsControlWidth)
                }
                wheelPreview
                SettingsFootnote(message: .settingsWheelSizeHint)
            }
            SettingsSection(title: .settingsAccessibility) {
                SettingsRow(label: .settingsLiquidGlass) {
                    AppToggle(key: .settingsLiquidGlass, isOn: liquidGlass)
                }
                SettingsDivider()
                SettingsRow(label: .settingsReduceMotion) {
                    AppToggle(key: .settingsReduceMotion, isOn: binding(\.reduceMotion))
                }
            }
            AppButton(key: .settingsResetCustomization, variant: .tertiary) {
                viewModel.reset()
                settings.selectAppearance(.system)
            }
        }
    }

    private var wheelPreview: some View {
        let scale = viewModel.preferences.wheelSize.scale
        return AppRadialWheel(
            wedges: ["PNG", "JPG", "WEBP", "TIFF", "HEIC", "PDF"].map {
                WheelWedgeContent(id: $0, label: .verbatim($0), symbol: nil)
            },
            geometry: WheelGeometry(wedgeCount: 6, innerRadius: AppDimensions.Wheel.innerRadius * scale,
                                    outerRadius: AppDimensions.Wheel.compactOuterRadius * scale,
                                    isRightToLeft: false),
            highlightedIndex: 0, hubTitle: .wheelConvert, hubGlyph: "⇧"
        )
        .scaleEffect(AppDimensions.CustomizationPreview.scale)
        // scaleEffect changes drawing, not layout. Reserve one stable viewport for every size
        // so the full-size wheel cannot widen the settings card or hosting window.
        .frame(width: AppDimensions.CustomizationPreview.viewport, height: AppDimensions.CustomizationPreview.viewport)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private var liquidGlass: Binding<Bool> {
        Binding(get: { !viewModel.preferences.solidSurfaces }, set: { enabled in
            viewModel.update { $0.solidSurfaces = !enabled }
        })
    }

    private var appearance: Binding<AppearanceMode> {
        Binding(get: { settings.state.appearance }, set: { settings.selectAppearance($0) })
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<InterfaceCustomization, Value>) -> Binding<Value> {
        Binding(get: { viewModel.preferences[keyPath: keyPath] }, set: { value in
            viewModel.update { $0[keyPath: keyPath] = value }
        })
    }

    private static let appearances: [AppSegmentedPicker<AppearanceMode>.Option] = [
        .init(value: .system, label: .appearanceSystem), .init(value: .light, label: .appearanceLight),
        .init(value: .dark, label: .appearanceDark)
    ]
    private static let sizes: [AppSegmentedPicker<InterfaceCustomization.WheelSize>.Option] = [
        .init(value: .compact, label: .settingsSizeCompact), .init(value: .standard, label: .settingsSizeStandard),
        .init(value: .large, label: .settingsSizeLarge)
    ]
}
