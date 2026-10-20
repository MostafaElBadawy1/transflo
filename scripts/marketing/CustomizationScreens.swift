import AppKit

/// Customization marketing frames, built from the full-resolution captures that
/// `CustomizationScreenshotUITests` saves to build/marketing/captures.
enum CustomizationScreens {
    private static let convertShare: CGFloat = 0.3455
    private static let toolsShare: CGFloat = 0.3252
    /// One wheel size: its capture name, caption and scale (matching `InterfaceCustomization.WheelSize`).
    private struct SizeSample {
        let name: String
        let title: String
        let scale: CGFloat
    }

    private static let accents = ["teal", "blue", "violet", "rose", "orange", "green"]
    private static let label = PromoTextStyle(size: 40, weight: .semibold, color: PromoPalette.textSecondary)

    static let screens: [MarketingFrame.Screen] = [
        MarketingFrame.Screen(
            name: "1-make-it-yours", eyebrow: "CUSTOMIZE",
            headline: "Make the wheel yours.",
            body: "Your color, your size, your keys and only the options you use. Every choice is saved.",
            art: hero
        ),
        MarketingFrame.Screen(
            name: "2-accent-colors", eyebrow: "SIX ACCENT COLORS",
            headline: "Your color, everywhere.",
            body: "Pick an accent and the wheel, highlights and controls follow it.",
            art: accentGrid(appearance: "dark")
        ),
        MarketingFrame.Screen(
            name: "3-light-and-dark", eyebrow: "LIGHT AND DARK",
            headline: "Follows your Mac's look.",
            body: "Every accent works in light and dark. Choose one, or let Transflo match the system.",
            art: tiles(accents.map { "accent-\($0)-light" }, columns: 3)
        ),
        MarketingFrame.Screen(
            name: "4-wheel-sizes", eyebrow: "THREE SIZES",
            headline: "Big petals or a compact wheel.",
            body: "Compact, Standard or Large: pick the size that suits your screen and your aim.",
            art: sizes
        ),
        MarketingFrame.Screen(
            name: "5-glass-or-solid", eyebrow: "LIQUID GLASS OR SOLID",
            headline: "Glass, or solid surfaces.",
            body: "Liquid Glass on macOS 26, a frosted look on earlier versions, or calm solid surfaces.",
            art: labeledTiles([("surface-glass-dark", "Glass"), ("surface-solid-dark", "Solid"),
                               ("surface-glass-light", "Glass"), ("surface-solid-light", "Solid")], columns: 2)
        ),
        MarketingFrame.Screen(
            name: "6-settings", eyebrow: "ONE SETTINGS WINDOW",
            headline: "Every choice in one place.",
            body: "Language, appearance, accent, wheel size, keys, haptics and tick sounds, all in General.",
            art: pair("settings-violet-dark", "settings-blue-light")
        )
    ]

    /// A large wheel in one accent, with two more accents tucked behind it. Only Convert and Tools appear:
    /// the Actions wheel shows Terminal, which the App Store edition doesn't have.
    private static func hero(_ canvas: PromoCanvas, _ area: CGRect, _ assets: PromoAssets) throws {
        // Fits the whole group (1 + 2 × 0.55 side wheel overlap) inside the area at any aspect.
        let side = min(area.width / 1.75, area.height * 0.8)
        let center = CGPoint(x: area.midX, y: area.midY + side * 0.04)
        let offset = side * 0.56
        canvas.circle(try assets.wheel("surface-glass-dark", radiusFraction: toolsShare),
                      center: CGPoint(x: center.x - offset, y: center.y + side * 0.16), diameter: side * 0.62)
        canvas.circle(try assets.wheel("accent-orange-dark", radiusFraction: convertShare),
                      center: CGPoint(x: center.x + offset, y: center.y + side * 0.16), diameter: side * 0.62)
        canvas.circle(try assets.wheel("accent-rose-light", radiusFraction: convertShare),
                      center: center, diameter: side)
    }

    /// The Convert wheel in every accent, as circles in a 3 × 2 grid.
    private static func accentGrid(appearance: String) -> MarketingFrame.Art {
        { canvas, area, assets in
            let columns = 3, rows = 2
            let cell = min(area.width / CGFloat(columns), area.height / CGFloat(rows))
            let origin = CGPoint(x: area.midX - cell * CGFloat(columns) / 2, y: area.midY - cell * CGFloat(rows) / 2)
            for (index, accent) in accents.enumerated() {
                let center = CGPoint(x: origin.x + cell * (CGFloat(index % columns) + 0.5),
                                     y: origin.y + cell * (CGFloat(index / columns) + 0.5))
                canvas.circle(try assets.wheel("accent-\(accent)-\(appearance)", radiusFraction: convertShare),
                              center: center, diameter: cell * 0.86)
            }
        }
    }

    /// Whole captures, accent backdrop included, as rounded tiles.
    private static func tiles(_ names: [String], columns: Int) -> MarketingFrame.Art {
        labeledTiles(names.map { ($0, nil) }, columns: columns)
    }

    private static func labeledTiles(_ items: [(String, String?)], columns: Int) -> MarketingFrame.Art {
        { canvas, area, assets in
            let rows = (items.count + columns - 1) / columns
            let hasLabels = items.contains { $0.1 != nil }
            let gap: CGFloat = 48
            let labelHeight: CGFloat = hasLabels ? 70 : 0
            let cell = min((area.width - gap * CGFloat(columns - 1)) / CGFloat(columns),
                           (area.height - gap * CGFloat(rows - 1)) / CGFloat(rows) - labelHeight)
            let totalWidth = cell * CGFloat(columns) + gap * CGFloat(columns - 1)
            let totalHeight = (cell + labelHeight) * CGFloat(rows) + gap * CGFloat(rows - 1)
            let origin = CGPoint(x: area.midX - totalWidth / 2, y: area.midY - totalHeight / 2)
            for (index, item) in items.enumerated() {
                let x = origin.x + (cell + gap) * CGFloat(index % columns)
                let y = origin.y + (cell + labelHeight + gap) * CGFloat(index / columns)
                canvas.roundedImage(try assets.image(item.0), in: CGRect(x: x, y: y, width: cell, height: cell),
                                    radius: cell * 0.08)
                if let text = item.1 {
                    canvas.text(text, center: CGPoint(x: x + cell / 2, y: y + cell + labelHeight / 2 + 6), style: label)
                }
            }
        }
    }

    /// Compact, Standard and Large at their true relative sizes, side by side.
    private static func sizes(_ canvas: PromoCanvas, _ area: CGRect, _ assets: PromoAssets) throws {
        let scales = [SizeSample(name: "compact", title: "Compact", scale: 0.9),
                      SizeSample(name: "standard", title: "Standard", scale: 1),
                      SizeSample(name: "large", title: "Large", scale: 1.15)]
        let gap: CGFloat = 60
        let unit = min((area.width - gap * 2) / scales.reduce(0) { $0 + $1.scale } * 0.92, area.height * 0.66)
        var x = area.midX - (unit * scales.reduce(0) { $0 + $1.scale } + gap * 2) / 2
        for sample in scales {
            let (name, title, scale) = (sample.name, sample.title, sample.scale)
            let diameter = unit * scale
            let center = CGPoint(x: x + diameter / 2, y: area.midY)
            canvas.circle(try assets.wheel("size-\(name)", radiusFraction: convertShare * scale),
                          center: center, diameter: diameter)
            canvas.text(title, center: CGPoint(x: center.x, y: area.midY + unit * 1.15 / 2 + 70), style: label)
            x += diameter + gap
        }
    }

    /// A large window with a second, smaller one overlapping its lower trailing corner.
    private static func pair(_ hero: String, _ inset: String) -> MarketingFrame.Art {
        { canvas, area, assets in
            let main = try assets.image(hero)
            let detail = try assets.image(inset)
            canvas.image(main, in: MarketingFrame.fit(main.size, in: CGRect(
                x: area.minX, y: area.minY, width: area.width * 0.8, height: area.height * 0.84)))
            let detailSize = MarketingFrame.fit(detail.size, in: CGRect(
                x: 0, y: 0, width: area.width * 0.5, height: area.height * 0.56)).size
            canvas.image(detail, in: CGRect(x: area.maxX - detailSize.width, y: area.maxY - detailSize.height,
                                            width: detailSize.width, height: detailSize.height))
        }
    }
}
