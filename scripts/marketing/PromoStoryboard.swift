import AppKit

/// Factory for the video's scenes, in order, built from the README screenshots.
enum PromoStoryboard {
    /// Each wheel's radius as a share of its screenshot's width (measured on the captures).
    private enum WheelShare {
        static let convert: CGFloat = 0.3455
        static let tools: CGFloat = 0.3252
        static let actions: CGFloat = 0.2864
    }

    static func timeline(assets: PromoAssets) throws -> PromoTimeline {
        let icon = try assets.image("icon")
        let wheelSettings = try assets.image("settings-wheel-dark")
        let opening: [any PromoScene] = [
            TitleScene(icon: icon),
            DragDemoScene(wheel: try assets.wheel("wheel-convert-en-dark", radiusFraction: WheelShare.convert)),
            WheelTrioScene(wheels: [
                .init(image: try assets.wheel("wheel-convert-en-dark", radiusFraction: WheelShare.convert), key: "⇧",
                      title: "Convert", detail: "288 conversions"),
                .init(image: try assets.wheel("wheel-tools-en-dark", radiusFraction: WheelShare.tools), key: "⌘",
                      title: "Tools", detail: "31 tools · grouped"),
                .init(image: try assets.wheel("wheel-actions-en-dark", radiusFraction: WheelShare.actions), key: "⌃",
                      title: "Actions", detail: "6 file actions")
            ]),
            ShowcaseScene(
                eyebrow: "Settings › Wheel",
                headline: "Only what you use.",
                detail: "Related tools share a group. Hover or click, then choose a tool. Back gives you time to move.",
                shots: [.init(image: wheelSettings, frame: fit(wheelSettings, centerX: 1330, top: 100, height: 880))],
                duration: 4.8
            )
        ]
        let scenes = opening + (try showcases(assets: assets)) + [ClosingScene(icon: icon)]
        return PromoTimeline(scenes: scenes, crossfade: 0.6)
    }

    /// A frame of `height` that keeps the screenshot's proportions, centered on `centerX`.
    private static func fit(_ image: NSImage, centerX: CGFloat, top: CGFloat, height: CGFloat) -> CGRect {
        let width = image.size.height > 0 ? height * image.size.width / image.size.height : height
        return CGRect(x: centerX - width / 2, y: top, width: width, height: height)
    }

    private static func showcases(assets: PromoAssets) throws -> [any PromoScene] {
        [
            ShowcaseScene(
                eyebrow: "Editors",
                headline: "Crop, beautify and annotate in place.",
                detail: "Editors open right where you dropped the file. No other app needed.",
                shots: [
                    .init(image: try assets.image("editor-addBackground-dark"),
                          frame: CGRect(x: 820, y: 130, width: 900, height: 703)),
                    .init(image: try assets.image("editor-crop-dark"),
                          frame: CGRect(x: 1500, y: 470, width: 330, height: 480), delay: 0.35)
                ]
            ),
            ShowcaseScene(
                eyebrow: "Compress",
                headline: "Choose your balance.",
                detail: "Best, Balanced or Smaller. Set your default in General. Originals stay untouched.",
                shots: [
                    .init(image: try assets.image("settings-output-dark"),
                          frame: CGRect(x: 900, y: 150, width: 880, height: 747))
                ],
                duration: 4.6
            ),
            ShowcaseScene(
                eyebrow: "",
                headline: "English and Arabic. Light and dark.",
                detail: "Every screen mirrors right to left and follows your Mac's appearance.",
                shots: [
                    .init(image: try assets.image("onboarding-2-en-light"),
                          frame: CGRect(x: 110, y: 330, width: 830, height: 534)),
                    .init(image: try assets.image("onboarding-2-ar-dark"),
                          frame: CGRect(x: 980, y: 330, width: 830, height: 534), delay: 0.3)
                ],
                layout: .textTop
            ),
            ShowcaseScene(
                eyebrow: "Customize",
                headline: "Make it yours.",
                detail: "Accent colors, wheel size, your own trigger keys and Liquid Glass.",
                shots: [
                    .init(image: try assets.image("settings-customization-dark"),
                          frame: CGRect(x: 900, y: 140, width: 900, height: 838))
                ],
                duration: 4.6
            )
        ]
    }
}
