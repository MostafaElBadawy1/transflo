import AppKit

/// A Finder-style file: a drawn landscape thumbnail above a selected name label.
struct PromoFileCard {
    let name: String

    static let thumbnailSize = CGSize(width: 150, height: 112)

    /// Draws the card with its thumbnail centered on `center`.
    func draw(on canvas: PromoCanvas, center: CGPoint) {
        let size = Self.thumbnailSize
        let frame = CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2,
                           width: size.width, height: size.height)
        drawThumbnail(in: frame)
        let style = PromoTextStyle(size: 22, weight: .semibold, color: .white)
        let label = NSAttributedString(string: name, attributes: style.attributes(alignment: .center))
        let width = label.size().width + 24
        let pill = CGRect(x: center.x - width / 2, y: frame.maxY + 12, width: width, height: 34)
        canvas.capsule(pill, color: PromoPalette.finderSelection)
        canvas.text(name, center: CGPoint(x: pill.midX, y: pill.midY), style: style)
    }

    private func drawThumbnail(in frame: CGRect) {
        let outer = NSBezierPath(roundedRect: frame, xRadius: 10, yRadius: 10)
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = PromoPalette.shadow
        shadow.shadowBlurRadius = 20
        shadow.shadowOffset = NSSize(width: 0, height: -8)
        shadow.set()
        NSColor.white.setFill()
        outer.fill()
        NSGraphicsContext.restoreGraphicsState()

        let photo = frame.insetBy(dx: 5, dy: 5)
        NSGraphicsContext.saveGraphicsState()
        NSBezierPath(roundedRect: photo, xRadius: 6, yRadius: 6).addClip()
        NSGradient(starting: PromoPalette.sky, ending: PromoPalette.paper)?.draw(in: photo, angle: 90)
        PromoPalette.sun.setFill()
        NSBezierPath(ovalIn: CGRect(x: photo.maxX - 48, y: photo.minY + 14, width: 30, height: 30)).fill()
        let hill = NSBezierPath()
        hill.move(to: CGPoint(x: photo.minX, y: photo.maxY))
        hill.line(to: CGPoint(x: photo.minX, y: photo.midY + 18))
        hill.curve(to: CGPoint(x: photo.maxX, y: photo.midY + 6),
                   controlPoint1: CGPoint(x: photo.midX - 20, y: photo.midY - 18),
                   controlPoint2: CGPoint(x: photo.midX + 30, y: photo.midY + 30))
        hill.line(to: CGPoint(x: photo.maxX, y: photo.maxY))
        hill.close()
        PromoPalette.hill.setFill()
        hill.fill()
        NSGraphicsContext.restoreGraphicsState()
    }
}
