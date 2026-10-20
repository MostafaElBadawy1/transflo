import AppKit
import SwiftUI

/// An opaque RGB color panel shared by editors; the persisted/export value is always #RRGGBB.
struct AppCustomColorPicker: View {
    @Environment(Localizer.self) private var localizer
    @Binding var selection: String

    var body: some View {
        ColorPicker(localizer.string(.settingsCustomColor), selection: color, supportsOpacity: false)
            .accessibilityIdentifier("transflo.editor.customColor")
    }

    private var color: Binding<Color> {
        Binding(get: { AppMarkupPalette.color(selection) }, set: { value in
            guard let rgb = NSColor(value).usingColorSpace(.sRGB) else { return }
            selection = String(format: "#%02X%02X%02X", Int((rgb.redComponent * 255).rounded()),
                               Int((rgb.greenComponent * 255).rounded()), Int((rgb.blueComponent * 255).rounded()))
        })
    }
}
