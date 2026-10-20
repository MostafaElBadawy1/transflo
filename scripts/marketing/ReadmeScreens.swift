import AppKit

/// Feature compositions for GitHub. Captured UI stays accurate; copy and diagrams explain the job.
enum ReadmeScreens {
    private struct WheelArtwork {
        let name: String
        let radius: CGFloat
        let center: CGPoint
        let label: String
        let diameter: CGFloat
    }

    static let screens: [MarketingFrame.Screen] = [
        .init(name: "wheels", eyebrow: "DRAG · TAP · DROP",
              headline: "One gesture. Three ways forward.",
              body: "⇧ Convert formats. ⌘ Edit with Tools. ⌃ Send, move or archive with Actions.",
              art: wheels),
        .init(name: "tools", eyebrow: "SMALL EDITS, FINISHED",
              headline: "Make the file ready to share.",
              body: "Crop, resize, annotate, redact or add a background. Related tools share one compact entry.",
              art: pair("editor-addBackground-dark", "editor-crop-dark")),
        .init(name: "recipes", eyebrow: "SAVE THE REPEAT WORK",
              headline: "Your workflow. One choice.",
              body: "Create a Recipe in Settings. Run it from Tools, or let a watch folder start it for you.",
              art: recipes),
        .init(name: "archives", eyebrow: "PACK IT. UNPACK IT.",
              headline: "Files together. Files back out.",
              body: "Actions → Archive makes one ZIP. Tools → Extract opens ZIP, RAR, TAR and GZIP in a new folder.",
              art: archives),
        .init(name: "customize", eyebrow: "AT HOME ON YOUR MAC",
              headline: "Keep only what you need.",
              body: "Choose wheel size, accent and shortcuts. Set Best, Balanced or Smaller output defaults.",
              art: pair("settings-customization-dark", "settings-wheel-dark"))
    ]

    private static func wheels(_ canvas: PromoCanvas, _ area: CGRect, _ assets: PromoAssets) throws {
        let diameter = area.width * 0.38
        let convertDiameter = area.width * 0.55
        let positions: [WheelArtwork] = [
            .init(name: "wheel-tools-en-dark", radius: 0.3252,
                  center: CGPoint(x: area.maxX - diameter * 0.5, y: area.minY + diameter * 0.5 + 50),
                  label: "⌘ Tools", diameter: diameter),
            .init(name: "wheel-actions-en-dark", radius: 0.2864,
                  center: CGPoint(x: area.maxX - diameter * 0.5, y: area.maxY - diameter * 0.5 - 100),
                  label: "⌃ Actions", diameter: diameter),
            .init(name: "wheel-convert-en-dark", radius: 0.3455,
                  center: CGPoint(x: area.minX + convertDiameter * 0.49, y: area.midY),
                  label: "⇧ Convert", diameter: convertDiameter)
        ]
        for wheel in positions {
            canvas.circle(try assets.wheel(wheel.name, radiusFraction: wheel.radius),
                          center: wheel.center, diameter: wheel.diameter)
            canvas.text(wheel.label, center: CGPoint(x: wheel.center.x, y: wheel.center.y + wheel.diameter * 0.57),
                        style: .init(size: 45, weight: .semibold, color: PromoPalette.textPrimary))
        }
    }

    private static func recipes(_ canvas: PromoCanvas, _ area: CGRect, _ assets: PromoAssets) throws {
        let diameter = min(area.width * 0.7, area.height * 0.65)
        canvas.circle(try assets.wheel("wheel-recipes-dark", radiusFraction: 0.3252),
                      center: CGPoint(x: area.midX, y: area.minY + diameter * 0.56), diameter: diameter)
        let y = area.maxY - 330
        let steps = ["Convert to JPG", "Resize to 2048 px", "Remove metadata"]
        for (index, step) in steps.enumerated() {
            let top = y + CGFloat(index) * 104
            canvas.text(String(index + 1), center: CGPoint(x: area.minX + 200, y: top),
                        style: .init(size: 42, weight: .bold, color: PromoPalette.accent))
            canvas.paragraph(step, origin: CGPoint(x: area.minX + 255, y: top - 28), width: area.width - 320,
                             style: .init(size: 48, weight: .medium, color: PromoPalette.textPrimary))
        }
    }

    private static func archives(_ canvas: PromoCanvas, _ area: CGRect, _ assets: PromoAssets) throws {
        let diameter = min(area.width * 0.66, area.height * 0.64)
        canvas.circle(try assets.wheel("wheel-actions-en-dark", radiusFraction: 0.2864),
                      center: CGPoint(x: area.midX, y: area.minY + diameter * 0.58), diameter: diameter)
        let center = CGPoint(x: area.midX, y: area.maxY - 240)
        canvas.text("Files + folders  →  ZIP", center: center,
                    style: .init(size: 60, weight: .bold, color: PromoPalette.textPrimary))
        canvas.text("ZIP · RAR · TAR · GZIP  →  Folder", center: CGPoint(x: center.x, y: center.y + 110),
                    style: .init(size: 45, weight: .medium, color: PromoPalette.accent))
    }

    private static func pair(_ mainName: String, _ detailName: String) -> MarketingFrame.Art {
        { canvas, area, assets in
            let main = try assets.image(mainName)
            let detail = try assets.image(detailName)
            let mainBounds = CGRect(x: area.minX, y: area.minY + 60,
                                    width: area.width * 0.86, height: area.height * 0.82)
            let detailBounds = CGRect(x: 0, y: 0, width: area.width * 0.5, height: area.height * 0.55)
            let detailSize = MarketingFrame.fit(detail.size, in: detailBounds).size
            canvas.image(main, in: MarketingFrame.centered(main.size, in: mainBounds))
            canvas.image(detail, in: CGRect(x: area.maxX - detailSize.width,
                                            y: area.maxY - detailSize.height,
                                            width: detailSize.width, height: detailSize.height))
        }
    }
}
