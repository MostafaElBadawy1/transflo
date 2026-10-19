import SwiftUI

/// A labeled single-line text field.
struct AppTextField: View {
    @Environment(Localizer.self) private var localizer
    let label: L10nKey
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.xSmall) {
            AppText(label)
            TextField(localizer.string(label), text: $text)
                .textFieldStyle(.roundedBorder)
                .labelsHidden()
        }
    }
}
