import SwiftUI

/// A labeled slider with its current value shown as text (already formatted by the caller).
struct AppSlider: View {
    @Environment(Localizer.self) private var localizer
    let label: L10nKey
    @Binding var value: Double
    let range: ClosedRange<Double>
    let valueText: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.xSmall) {
            HStack {
                AppText(label, style: .body)
                Spacer()
                AppText(verbatim: valueText, style: .caption, color: .secondary)
            }
            Slider(value: $value, in: range)
                .tint(AppColors.accent)
                .labelsHidden()
                .accessibilityLabel(localizer.string(label))
        }
    }
}
