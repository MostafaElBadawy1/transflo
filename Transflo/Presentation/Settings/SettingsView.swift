import SwiftUI
import TransfloDomain

/// General preferences, visual customization, the wheels' choices, keys and output in separate tabs.
struct SettingsView: View {
    let viewModel: SettingsViewModel
    let keys: KeySettingsViewModel
    let customization: CustomizationViewModel
    let tools: ToolPreferencesViewModel
    let wheel: WheelVisibilityViewModel
    @State private var selectedTab = Tab.general
    @State private var contentHeights: [Tab: CGFloat] = [:]

    private enum Tab: Hashable {
        case general, customization, wheel, keys, output
    }

    var body: some View {
        VStack(spacing: .zero) {
            AppSegmentedPicker(key: .settingsTitle, selection: $selectedTab, options: Self.tabs)
                .frame(height: AppDimensions.Window.settingsTabChrome)
                .accessibilityIdentifier("settings.tabs")
            selectedPage
        }
        .padding(AppDimensions.Spacing.medium)
        .frame(width: AppDimensions.Window.settingsWidth, height: windowHeight)
        .background(AppWindowBackdrop().ignoresSafeArea())
        .animation(AppAnimations.standard, value: viewModel.state.errorState)
    }

    private static let tabs: [AppSegmentedPicker<Tab>.Option] = [
        .init(value: .general, label: .settingsGeneralSection),
        .init(value: .customization, label: .settingsCustomization), .init(value: .wheel, label: .settingsWheel),
        .init(value: .keys, label: .settingsKeysSection), .init(value: .output, label: .settingsOutput)
    ]

    /// Keep only the active page mounted. Native TabView retains hidden AppKit pickers,
    /// which can paint stale segmented-control layers during an intrinsic window resize.
    @ViewBuilder private var selectedPage: some View {
        switch selectedTab {
        case .general: page(.general) { general }
        case .customization:
            page(.customization) { CustomizationSettingsView(settings: viewModel, viewModel: customization) }
        case .wheel: page(.wheel) { WheelVisibilitySettingsView(model: wheel) }
        case .keys: page(.keys) { KeySettingsSection(viewModel: keys) }
        case .output: page(.output) { OutputPreferencesView(model: tools) }
        }
    }

    /// Measure natural content independently of the viewport, so short tabs can shrink again.
    private func page<Content: View>(_ tab: Tab, @ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            content()
                .fixedSize(horizontal: false, vertical: true)
                .padding(AppDimensions.Spacing.xLarge)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                    contentHeights[tab] = height
                }
        }
        .scrollBounceBehavior(.basedOnSize)
        .defaultScrollAnchor(.top)
        .id(tab)
    }

    private var windowHeight: CGFloat {
        // Native tab chrome plus outer padding; long pages retain a bounded scroll area.
        let content = contentHeights[selectedTab] ?? AppDimensions.Window.settingsMinContentHeight
        return min(content + AppDimensions.Window.settingsTabChrome + AppDimensions.Spacing.medium * 2,
                   AppDimensions.Window.settingsMaxHeight)
    }

    private var general: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.xLarge) {
            SettingsSection(title: .settingsGeneralSection) {
                SettingsRow(label: .settingsLanguage) {
                    AppSegmentedPicker(key: .settingsLanguage, selection: language, options: Self.languageOptions)
                }
                SettingsDivider()
                SettingsRow(label: .settingsLaunchAtLogin) {
                    AppToggle(key: .settingsLaunchAtLogin, isOn: launchAtLogin)
                }
                if let error = viewModel.state.errorState {
                    SettingsFootnote(message: error.messageKey, tone: .danger)
                }
            }
            SettingsSection(title: .settingsAboutSection) {
                SettingsRow(label: .appName) {
                    AppText(.settingsVersion, arguments: versionArguments, color: .secondary)
                }
            }
        }
    }

    private static let languageOptions: [AppSegmentedPicker<AppLanguage>.Option] = [
        .init(value: .english, label: .languageEnglish),
        .init(value: .arabic, label: .languageArabic)
    ]

    private var language: Binding<AppLanguage> {
        Binding(get: { viewModel.state.language }, set: { viewModel.selectLanguage($0) })
    }

    private var launchAtLogin: Binding<Bool> {
        Binding(get: { viewModel.state.launchAtLogin }, set: { viewModel.setLaunchAtLoginEnabled($0) })
    }

    private var versionArguments: [String] {
        [viewModel.state.version.marketing, viewModel.state.version.build]
    }
}
