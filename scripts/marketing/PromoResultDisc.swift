import AppKit

/// The app's result disc, drawn for the video: a glass disc with a well, a progress ring that fills
/// clockwise from the top, and a tick that draws itself in.
struct PromoResultDisc {
    let diameter: CGFloat

    /// - Parameters:
    ///   - progress: How far the ring has filled, 0…1.
    ///   - tick: How much of the tick is drawn, 0…1.
    func draw(on canvas: PromoCanvas, center: CGPoint, progress: Double, tick: Double) {
        let disc = CGRect(x: center.x - diameter / 2, y: center.y - diameter / 2, width: diameter, height: diameter)
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = PromoPalette.shadow
        shadow.shadowBlurRadius = 40
        shadow.shadowOffset = NSSize(width: 0, height: -14)
        shadow.set()
        PromoPalette.pill.setFill()
        NSBezierPath(ovalIn: disc).fill()
        NSGraphicsContext.restoreGraphicsState()
        PromoPalette.well.setFill()
        NSBezierPath(ovalIn: disc.insetBy(dx: diameter * 0.05, dy: diameter * 0.05)).fill()

        let ringRadius = diameter * 0.37
        let stroke = diameter * 0.055
        let track = NSBezierPath(ovalIn: CGRect(x: center.x - ringRadius, y: center.y - ringRadius,
                                                width: ringRadius * 2, height: ringRadius * 2))
        track.lineWidth = stroke
        PromoPalette.track.setStroke()
        track.stroke()
        if progress > 0 {
            let arc = Self.arc(center: center, radius: ringRadius, fraction: min(progress, 1))
            arc.lineWidth = stroke
            arc.lineCapStyle = .round
            PromoPalette.accent.setStroke()
            arc.stroke()
        }
        if tick > 0 {
            let check = Self.tick(center: center, size: diameter * 0.36, fraction: min(tick, 1))
            check.lineWidth = stroke * 1.15
            check.lineCapStyle = .round
            check.lineJoinStyle = .round
            PromoPalette.accent.setStroke()
            check.stroke()
        }
    }

    /// Clockwise from twelve o'clock in the top-left coordinate space.
    private static func arc(center: CGPoint, radius: CGFloat, fraction: Double) -> NSBezierPath {
        let path = NSBezierPath()
        let steps = max(2, Int(fraction * 120))
        for step in 0...steps {
            let angle = -Double.pi / 2 + 2 * Double.pi * fraction * Double(step) / Double(steps)
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if step == 0 { path.move(to: point) } else { path.line(to: point) }
        }
        return path
    }

    /// The first `fraction` of a tick's length, so it reads as being drawn.
    private static func tick(center: CGPoint, size: CGFloat, fraction: Double) -> NSBezierPath {
        let corners = [CGPoint(x: -0.5, y: 0.02), CGPoint(x: -0.14, y: 0.36), CGPoint(x: 0.5, y: -0.34)]
            .map { CGPoint(x: center.x + $0.x * size, y: center.y + $0.y * size) }
        let lengths = zip(corners, corners.dropFirst()).map { hypot($1.x - $0.x, $1.y - $0.y) }
        var remaining = lengths.reduce(0, +) * fraction
        let path = NSBezierPath()
        path.move(to: corners[0])
        for (index, length) in lengths.enumerated() where remaining > 0 {
            let share = min(1, remaining / length)
            let from = corners[index]
            let to = corners[index + 1]
            path.line(to: CGPoint(x: from.x + (to.x - from.x) * share, y: from.y + (to.y - from.y) * share))
            remaining -= length
        }
        return path
    }
}
