import AppKit

/// The Mac App Store screenshots: 2880 × 1800 frames that pair one message with the real UI.
///
/// The Actions capture comes from APP_STORE mode, which excludes the Terminal action.
enum AppStoreScreens {
    static let screens: [MarketingFrame.Screen] = [
        .init(name: "01-convert", eyebrow: "DRAG · TAP A KEY · DROP",
              headline: "Convert files right at your cursor.",
              body: "Images, media, PDF and more. See only the conversions that work for your selected files.",
              art: wheels),
        .init(name: "02-grouped-tools", eyebrow: "31 TOOLS, COMPACT GROUPS",
              headline: "Find your next edit. Fast.",
              body: "Related tools share one entry. Open a group, choose a tool and use Back to return at your pace.",
              art: tools),
        .init(name: "03-images", eyebrow: "READY TO SHARE",
              headline: "Give every image its finishing touch.",
              body: "Crop, resize, adjust, annotate or redact. Remove a background, add one or build a collage.",
              art: pair("editor-addBackground-dark", "editor-crop-dark")),
        .init(name: "04-pdf", eyebrow: "YOUR PDF, IN ORDER",
              headline: "Keep the pages that matter.",
              body: "Reorder, split, merge or extract pages. Add markup and redact before sharing.",
              art: pair("editor-reorganizePages-light", "editor-annotate-light")),
        .init(name: "05-media", eyebrow: "VIDEO AND AUDIO",
              headline: "A better cut. A clearer sound.",
              body: "Trim, split or merge clips. Change speed, mute, bleep and normalize loudness "
                + "with playback previews.",
              art: pair("editor-trim-dark", "editor-normalize-dark")),
        .init(name: "06-recipes", eyebrow: "SAVE THE REPEAT WORK",
              headline: "Your workflow. One choice.",
              body: "Chain steps into a Recipe. Run it from Tools, a watch folder or Shortcuts.",
              art: recipes),
        .init(name: "07-archives", eyebrow: "PACK IT. UNPACK IT.",
              headline: "Files together. Files back out.",
              body: "Archive files and folders into one ZIP. Extract ZIP, RAR, TAR and GZIP into a new folder.",
              art: archives),
        .init(name: "08-compression", eyebrow: "CHOOSE YOUR BALANCE",
              headline: "Smaller files. Your priorities.",
              body: "Set Best, Balanced or Smaller defaults. Preview the options for each compression job.",
              art: pair("editor-compress-dark", "settings-output-dark")),
        .init(name: "09-customization", eyebrow: "MADE TO FIT YOUR MAC",
              headline: "Only the options you use.",
              body: "Choose your accent, wheel size and keys. Hide formats, tools and actions you never need.",
              art: pair("settings-customization-dark", "settings-wheel-dark")),
        .init(name: "10-arabic", eyebrow: "ENGLISH · العربية",
              headline: "At home in either language.",
              body: "English and Arabic, full right-to-left layout, light and dark. File processing stays on your Mac.",
              art: single("onboarding-2-ar-dark"))
    ]

    private static func tools(_ canvas: PromoCanvas, _ area: CGRect, _ assets: PromoAssets) throws {
        canvas.circle(try assets.wheel("wheel-tools-en-dark", radiusFraction: 0.3252),
                      center: CGPoint(x: area.midX, y: area.midY),
                      diameter: min(area.width * 0.9, area.height * 0.9))
    }

    private static func recipes(_ canvas: PromoCanvas, _ area: CGRect, _ assets: PromoAssets) throws {
        let settings = try assets.image("settings-recipes-dark")
        let bounds = CGRect(x: area.minX, y: area.minY, width: area.width * 0.86, height: area.height * 0.86)
        canvas.image(settings, in: MarketingFrame.fit(settings.size, in: bounds))
        let diameter = area.width * 0.49
        canvas.circle(try assets.wheel("wheel-recipes-dark", radiusFraction: 0.3252),
                      center: CGPoint(x: area.maxX - diameter / 2, y: area.maxY - diameter / 2),
                      diameter: diameter)
    }

    private static func archives(_ canvas: PromoCanvas, _ area: CGRect, _ assets: PromoAssets) throws {
        canvas.circle(try assets.wheel("appstore-actions-dark", radiusFraction: 0.2864),
                      center: CGPoint(x: area.midX, y: area.midY),
                      diameter: min(area.width * 0.9, area.height * 0.9))
    }

    /// The Convert wheel with the Tools wheel tucked behind it.
    private static func wheels(_ canvas: PromoCanvas, _ area: CGRect, _ assets: PromoAssets) throws {
        let side = min(area.width * 0.56, area.height * 0.86)
        let center = CGPoint(x: area.midX - side * 0.18, y: area.midY)
        let toolsCenter = CGPoint(x: center.x + side * 0.66, y: center.y + side * 0.2)
        canvas.circle(try assets.wheel("wheel-tools-en-dark", radiusFraction: 0.3252),
                      center: toolsCenter, diameter: side * 0.66)
        canvas.circle(try assets.wheel("wheel-convert-en-dark", radiusFraction: 0.3455),
                      center: center, diameter: side)
    }

    /// One screenshot, centered.
    private static func single(_ name: String) -> MarketingFrame.Art {
        { canvas, area, assets in
            let image = try assets.image(name)
            let rect = MarketingFrame.fit(image.size, in: area)
            canvas.image(image, in: rect.offsetBy(dx: (area.width - rect.width) / 2,
                                                  dy: (area.height - rect.height) / 2))
        }
    }

    /// A large screenshot with a second, smaller one overlapping its lower trailing corner.
    private static func pair(_ hero: String, _ inset: String) -> MarketingFrame.Art {
        { canvas, area, assets in
            let main = try assets.image(hero)
            let detail = try assets.image(inset)
            let heroBounds = CGRect(x: area.minX, y: area.minY, width: area.width * 0.82, height: area.height * 0.86)
            let detailBounds = CGRect(x: 0, y: 0, width: area.width * 0.42, height: area.height * 0.56)
            let detailSize = MarketingFrame.fit(detail.size, in: detailBounds).size
            canvas.image(main, in: MarketingFrame.fit(main.size, in: heroBounds))
            canvas.image(detail, in: CGRect(x: area.maxX - detailSize.width, y: area.maxY - detailSize.height,
                                            width: detailSize.width, height: detailSize.height))
        }
    }
}
