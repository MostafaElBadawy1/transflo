import SwiftUI
import TransfloDomain

/// Settings › Wheel: pick a wheel, then tick the options it should show.
struct WheelVisibilitySettingsView: View {
    let model: WheelVisibilityViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.xLarge) {
            SettingsSection(title: .settingsWheelSection) {
                AppSegmentedPicker(key: .settingsWheelChoose, selection: wheel, options: Self.wheels)
                    .accessibilityIdentifier("settings.wheel.picker")
                SettingsFootnote(message: model.wheel == .convert ? .settingsWheelConvertHint : .settingsWheelHint)
            }
            SettingsSection(title: WheelPresentation.title(for: model.wheel)) {
                header
                if model.isWheelEmpty {
                    SettingsFootnote(message: .settingsWheelEmpty, tone: .danger)
                }
                ForEach(model.groups) { group in
                    checklist(group)
                }
            }
        }
        .animation(AppAnimations.standard, value: model.isWheelEmpty)
    }

    private var header: some View {
        HStack(spacing: AppDimensions.Spacing.small) {
            AppText(.settingsWheelShownCount, arguments: [String(model.shownCount), String(model.totalCount)],
                    style: .headline)
                .accessibilityIdentifier("settings.wheel.count")
            Spacer(minLength: AppDimensions.Spacing.small)
            AppButton(key: .settingsWheelShowAll, variant: .tertiary,
                      isEnabled: model.shownCount < model.totalCount) { model.showAll() }
            AppButton(key: .settingsWheelHideAll, variant: .tertiary,
                      isEnabled: model.shownCount > 0) { model.hideAll() }
        }
    }

    private func checklist(_ group: WheelVisibilityViewModel.Group) -> some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.small) {
            if let title = group.title {
                AppText(title, style: .caption, color: .secondary)
            }
            LazyVGrid(columns: Self.columns, alignment: .leading, spacing: AppDimensions.Spacing.small) {
                ForEach(group.rows) { row in
                    AppCheckbox(label: row.label, symbol: row.symbol, isOn: binding(for: row))
                        .accessibilityIdentifier("settings.wheel.\(row.id)")
                }
            }
        }
    }

    private func binding(for row: WheelVisibilityViewModel.Row) -> Binding<Bool> {
        Binding(get: { model.isVisible(row) }, set: { model.setVisible(row, $0) })
    }

    private var wheel: Binding<WheelKind> {
        Binding(get: { model.wheel }, set: { model.select($0) })
    }

    private static let columns = [
        GridItem(.adaptive(minimum: AppDimensions.Checkbox.gridMinColumn), alignment: .leading)
    ]

    private static let wheels: [AppSegmentedPicker<WheelKind>.Option] = [
        .init(value: .convert, label: .wheelConvert), .init(value: .tools, label: .wheelTools),
        .init(value: .actions, label: .wheelActions)
    ]
}
