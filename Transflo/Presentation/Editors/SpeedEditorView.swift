import SwiftUI
import TransfloDomain

/// Change-speed editor: a rate slider and the resulting length.
struct SpeedEditorView: View {
    @Bindable var model: SpeedEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppSlider(label: .editorSpeed, value: $model.factor, range: ToolSettings.speedRange,
                      valueText: model.factor.formatted(.number.precision(.fractionLength(2))) + "×")
            if let length = model.newDuration {
                AppText(.editorNewLength, arguments: [TimeLabel.text(length)], style: .caption, color: .secondary)
            }
        }
    }
}
