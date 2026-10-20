import Foundation
import XCTest

/// Full-resolution captures for customization marketing (accent colors, wheel sizes, glass or solid),
/// saved to build/marketing/captures by `scripts/capture-screenshots.sh`; not README assets.
@MainActor
final class CustomizationScreenshotUITests: MarketingCaptureTestCase {
    /// The accent presets offered in Settings › General, by file-name tag (nil is the original teal).
    private static let accents: [(tag: String, hex: String?)] = [
        ("teal", nil), ("blue", "2563EB"), ("violet", "7C3AED"),
        ("rose", "BE185D"), ("orange", "C2410C"), ("green", "15803D")
    ]

    /// Launch arguments that preset the saved customization (the argument domain reads `<hex>` as data).
    private func customization(accent: String? = nil, size: String = "standard", solid: Bool = false) -> [String] {
        var values: [String: Any] = ["wheelSize": size, "solidSurfaces": solid, "reduceMotion": false,
                                     "wheelHaptics": true, "wheelSound": true]
        if let accent { values["accentHex"] = accent }
        let data = (try? JSONSerialization.data(withJSONObject: values, options: [.sortedKeys])) ?? Data()
        return ["-settings.customization", "<" + data.map { String(format: "%02x", $0) }.joined() + ">"]
    }

    private func captureWheel(_ wheel: String, appearance: String, name: String, preset: [String]) {
        let app = launch([LaunchArgument.previewWheel, wheel], appearance: appearance, backdrop: true,
                         extraArguments: preset)
        capture(app.dialogs[WindowIdentifier.wheel], name, prefix: "marketing")
        app.terminate()
    }

    func testAccentColors() {
        for accent in Self.accents {
            for appearance in ["dark", "light"] {
                captureWheel("convert", appearance: appearance, name: "accent-\(accent.tag)-\(appearance)",
                             preset: customization(accent: accent.hex))
            }
        }
    }

    func testSizesAndSurfaces() {
        for size in ["compact", "standard", "large"] {
            captureWheel("convert", appearance: "dark", name: "size-\(size)", preset: customization(size: size))
        }
        for (solid, tag) in [(false, "glass"), (true, "solid")] {
            for appearance in ["dark", "light"] {
                captureWheel("tools", appearance: appearance, name: "surface-\(tag)-\(appearance)",
                             preset: customization(accent: "7C3AED", solid: solid))
            }
        }
        captureWheel("actions", appearance: "light", name: "actions-orange-light",
                     preset: customization(accent: "C2410C"))
    }

    func testSettingsInAccent() {
        for (accent, appearance) in [("7C3AED", "dark"), ("2563EB", "light")] {
            let app = launch([LaunchArgument.openSettings], appearance: appearance,
                             extraArguments: customization(accent: accent))
            let settings = app.windows[WindowIdentifier.settings]
            XCTAssertTrue(settings.staticTexts["Accent color"].waitForExistence(timeout: 15))
            capture(settings, "settings-\(accent == "7C3AED" ? "violet" : "blue")-\(appearance)", prefix: "marketing")
            app.terminate()
        }
    }
}
