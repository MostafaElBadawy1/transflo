import AppKit

/// Renders still marketing frames: one message beside the real UI. Landscape frames put the copy
/// in the left third; square frames put it above the artwork.
enum MarketingFrame {
    static let landscape = CGSize(width: 2880, height: 1800)
    static let square = CGSize(width: 2160, height: 2160)

    typealias Art = (PromoCanvas, CGRect, PromoAssets) throws -> Void

    struct Screen {
        let name: String
        let eyebrow: String
        let headline: String
        let body: String
        let art: Art
    }

    private struct TextBlock {
        let text: String
        let style: PromoTextStyle
        let gapAfter: CGFloat
    }

    private static let eyebrow = PromoTextStyle(size: 44, weight: .semibold, color: PromoPalette.accent, tracking: 5)
    private static let headline = PromoTextStyle(
        size: 128, weight: .bold, color: PromoPalette.textPrimary, tracking: -2
    )
    private static let body = PromoTextStyle(size: 54, weight: .regular, color: PromoPalette.textSecondary)

    static func draw(_ screen: Screen, on canvas: PromoCanvas, size: CGSize, assets: PromoAssets) throws {
        canvas.backdrop()
        let blocks = [
            TextBlock(text: screen.eyebrow, style: eyebrow, gapAfter: 36),
            TextBlock(text: screen.headline, style: headline, gapAfter: 48),
            TextBlock(text: screen.body, style: body, gapAfter: 0)
        ]
        let margin: CGFloat = 150
        if size.width > size.height * 1.2 {
            let column = CGRect(x: margin, y: 0, width: 880, height: size.height)
            let total = blocks.reduce(0) { $0 + height(of: $1, width: column.width) + $1.gapAfter }
            write(blocks, on: canvas, at: CGPoint(x: column.minX, y: (size.height - total) / 2), width: column.width)
            try screen.art(canvas, CGRect(x: column.maxX + 110, y: 120,
                                          width: size.width - column.maxX - 110 - margin / 2,
                                          height: size.height - 240), assets)
        } else {
            let width = size.width - margin * 2
            let used = write(blocks, on: canvas, at: CGPoint(x: margin, y: 150), width: width)
            let top = 150 + used + 90
            try screen.art(canvas, CGRect(x: margin / 2, y: top, width: size.width - margin,
                                          height: size.height - top - 110), assets)
        }
    }

    /// Writes the copy from `origin` down and returns the height it took.
    @discardableResult
    private static func write(
        _ blocks: [TextBlock],
        on canvas: PromoCanvas,
        at origin: CGPoint,
        width: CGFloat
    ) -> CGFloat {
        var top = origin.y
        for block in blocks {
            top += canvas.paragraph(block.text, origin: CGPoint(x: origin.x, y: top), width: width,
                                    style: block.style) + block.gapAfter
        }
        return top - origin.y
    }

    private static func height(of block: TextBlock, width: CGFloat) -> CGFloat {
        let attributed = NSAttributedString(string: block.text, attributes: block.style.attributes(alignment: .left))
        let bounds = attributed.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                             options: [.usesLineFragmentOrigin, .usesFontLeading])
        return ceil(bounds.height)
    }

    /// The largest rectangle with `size`'s proportions inside `bounds`, at its top leading corner.
    static func fit(_ size: CGSize, in bounds: CGRect) -> CGRect {
        let scale = min(bounds.width / size.width, bounds.height / size.height)
        return CGRect(x: bounds.minX, y: bounds.minY, width: size.width * scale, height: size.height * scale)
    }

    /// `fit`, centered in `bounds`.
    static func centered(_ size: CGSize, in bounds: CGRect) -> CGRect {
        let rect = fit(size, in: bounds)
        return rect.offsetBy(dx: (bounds.width - rect.width) / 2, dy: (bounds.height - rect.height) / 2)
    }
}
