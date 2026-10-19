import AppKit

/// Font, color and tracking for one kind of on-screen text.
struct PromoTextStyle {
    let size: CGFloat
    let weight: NSFont.Weight
    let color: NSColor
    var tracking: CGFloat = 0
    var monospaced = false

    static let display = Self(size: 120, weight: .bold, color: PromoPalette.textPrimary, tracking: -2)
    static let headline = Self(size: 64, weight: .bold, color: PromoPalette.textPrimary, tracking: -1)
    static let body = Self(size: 32, weight: .regular, color: PromoPalette.textSecondary)
    static let eyebrow = Self(size: 24, weight: .semibold, color: PromoPalette.accent, tracking: 3)
    static let label = Self(size: 34, weight: .semibold, color: PromoPalette.textPrimary)
    static let caption = Self(size: 26, weight: .regular, color: PromoPalette.textSecondary)
    static let code = Self(size: 30, weight: .medium, color: PromoPalette.textPrimary, monospaced: true)

    func attributes(alignment: NSTextAlignment) -> [NSAttributedString.Key: Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineHeightMultiple = 1.08
        let font = monospaced
            ? NSFont.monospacedSystemFont(ofSize: size, weight: weight)
            : NSFont.systemFont(ofSize: size, weight: weight)
        return [.font: font, .foregroundColor: color, .kern: tracking, .paragraphStyle: paragraph]
    }
}
