import AppKit

/// Adapter over AppKit drawing for one video frame, in a top-left coordinate space.
struct PromoCanvas {
    let size: CGSize
    let context: CGContext

    /// Flips `context` to top-left coordinates, makes it current for AppKit and runs `body`.
    static func render(on context: CGContext, size: CGSize, _ body: (PromoCanvas) -> Void) {
        context.saveGState()
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: true)
        body(PromoCanvas(size: size, context: context))
        NSGraphicsContext.restoreGraphicsState()
        context.restoreGState()
    }

    var bounds: CGRect { CGRect(origin: .zero, size: size) }

    func backdrop() {
        let gradient = NSGradient(starting: PromoPalette.inkTop, ending: PromoPalette.inkBottom)
        gradient?.draw(in: bounds, angle: 90)
    }

    /// Draws `body` as one group at `alpha`, so overlapping parts fade together.
    func layer(alpha: Double, _ body: () -> Void) {
        guard alpha > 0.001 else { return }
        context.saveGState()
        context.setAlpha(alpha)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        body()
        context.endTransparencyLayer()
        context.restoreGState()
    }

    /// Scales `body` around `point`, then moves it by `offset`.
    func transformed(scale: Double, around point: CGPoint, offset: CGSize = .zero, _ body: () -> Void) {
        context.saveGState()
        context.translateBy(x: point.x + offset.width, y: point.y + offset.height)
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -point.x, y: -point.y)
        body()
        context.restoreGState()
    }

    /// Fades `body` in while it rises `distance` points into place, starting at `start` seconds.
    func reveal(at time: Double, start: Double, distance: CGFloat = 24, _ body: () -> Void) {
        let amount = PromoEasing.outCubic(PromoEasing.progress(time, from: start, to: start + 0.6))
        layer(alpha: amount) {
            transformed(scale: 1, around: .zero, offset: CGSize(width: 0, height: (1 - amount) * distance), body)
        }
    }

    /// One line of text centered on `center`.
    func text(_ string: String, center: CGPoint, style: PromoTextStyle) {
        let attributed = NSAttributedString(string: string, attributes: style.attributes(alignment: .center))
        let measured = attributed.size()
        attributed.draw(at: CGPoint(x: center.x - measured.width / 2, y: center.y - measured.height / 2))
    }

    /// Wrapped text inside `width`, starting at `origin`. Returns the height used.
    @discardableResult
    func paragraph(
        _ string: String,
        origin: CGPoint,
        width: CGFloat,
        style: PromoTextStyle,
        alignment: NSTextAlignment = .left
    ) -> CGFloat {
        let attributed = NSAttributedString(string: string, attributes: style.attributes(alignment: alignment))
        let options: NSString.DrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let height = ceil(attributed.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                  options: options).height)
        attributed.draw(with: CGRect(x: origin.x, y: origin.y, width: width, height: height), options: options)
        return height
    }

    /// A screenshot with a soft drop shadow that follows its transparent corners.
    func image(_ image: NSImage, in rect: CGRect) {
        NSGraphicsContext.saveGraphicsState()
        shadow(radius: 48, drop: 18).set()
        image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true,
                   hints: [.interpolation: NSImageInterpolation.high])
        NSGraphicsContext.restoreGraphicsState()
    }

    /// `image` clipped to a rounded rectangle, with a shadow beneath.
    func roundedImage(_ image: NSImage, in rect: CGRect, radius: CGFloat) {
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        NSGraphicsContext.saveGraphicsState()
        shadow(radius: 40, drop: 16).set()
        PromoPalette.inkBottom.setFill()
        path.fill()
        NSGraphicsContext.restoreGraphicsState()
        NSGraphicsContext.saveGraphicsState()
        path.addClip()
        image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true,
                   hints: [.interpolation: NSImageInterpolation.high])
        NSGraphicsContext.restoreGraphicsState()
    }

    /// `image` clipped to a circle of `diameter` around `center`, with a shadow beneath.
    func circle(_ image: NSImage, center: CGPoint, diameter: CGFloat) {
        let rect = CGRect(x: center.x - diameter / 2, y: center.y - diameter / 2, width: diameter, height: diameter)
        let path = NSBezierPath(ovalIn: rect)
        NSGraphicsContext.saveGraphicsState()
        shadow(radius: 60, drop: 24).set()
        PromoPalette.inkBottom.setFill()
        path.fill()
        NSGraphicsContext.restoreGraphicsState()
        NSGraphicsContext.saveGraphicsState()
        path.addClip()
        image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true,
                   hints: [.interpolation: NSImageInterpolation.high])
        NSGraphicsContext.restoreGraphicsState()
    }

    /// A light keyboard key showing `glyph`, centered on `center`.
    func keycap(_ glyph: String, center: CGPoint, side: CGFloat) {
        let face = CGRect(x: center.x - side / 2, y: center.y - side / 2, width: side, height: side)
        let radius = side * 0.2
        NSGraphicsContext.saveGraphicsState()
        shadow(radius: 24, drop: 10).set()
        PromoPalette.paperEdge.setFill()
        NSBezierPath(roundedRect: face.offsetBy(dx: 0, dy: side * 0.06), xRadius: radius, yRadius: radius).fill()
        NSGraphicsContext.restoreGraphicsState()
        PromoPalette.paper.setFill()
        NSBezierPath(roundedRect: face, xRadius: radius, yRadius: radius).fill()
        let style = PromoTextStyle(size: side * 0.46, weight: .medium, color: PromoPalette.ink)
        text(glyph, center: CGPoint(x: center.x, y: center.y - side * 0.02), style: style)
    }

    /// The macOS arrow pointer with its tip at `tip`.
    func cursor(at tip: CGPoint, scale: CGFloat = 1.5) {
        let outline: [CGPoint] = [
            CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 30), CGPoint(x: 7, y: 23), CGPoint(x: 12, y: 35),
            CGPoint(x: 17, y: 33), CGPoint(x: 12, y: 21), CGPoint(x: 22, y: 21)
        ]
        let path = NSBezierPath()
        for (index, point) in outline.enumerated() {
            let placed = CGPoint(x: tip.x + point.x * scale, y: tip.y + point.y * scale)
            if index == 0 { path.move(to: placed) } else { path.line(to: placed) }
        }
        path.close()
        path.lineJoinStyle = .round
        path.lineWidth = 2.2
        NSGraphicsContext.saveGraphicsState()
        shadow(radius: 8, drop: 3).set()
        NSColor.black.setFill()
        path.fill()
        NSGraphicsContext.restoreGraphicsState()
        NSColor.white.setStroke()
        path.stroke()
    }

    /// Fills a capsule behind content, for pills such as the install command.
    func capsule(_ rect: CGRect, color: NSColor) {
        color.setFill()
        NSBezierPath(roundedRect: rect, xRadius: rect.height / 2, yRadius: rect.height / 2).fill()
    }

    /// Shadows are set in device space, where a negative height falls downward.
    private func shadow(radius: CGFloat, drop: CGFloat) -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = PromoPalette.shadow
        shadow.shadowBlurRadius = radius
        shadow.shadowOffset = NSSize(width: 0, height: -drop)
        return shadow
    }
}
