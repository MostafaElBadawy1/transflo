import AppKit

// Render at 2× for crisp text on Retina displays; Finder sees a 640 × 350 point image.
let width: CGFloat = 640
let height: CGFloat = 350
let output = URL(fileURLWithPath: CommandLine.arguments[1])
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: 1280, pixelsHigh: 700,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
), let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else { exit(1) }
bitmap.size = NSSize(width: width, height: height)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics
let context = graphics.cgContext
context.scaleBy(x: 2, y: 2)
let backdrop = NSColor(srgbRed: 0.96, green: 0.97, blue: 0.965, alpha: 1)
let ink = NSColor(srgbRed: 0.10, green: 0.16, blue: 0.15, alpha: 1)
let muted = NSColor(srgbRed: 0.39, green: 0.45, blue: 0.43, alpha: 1)
let teal = NSColor(srgbRed: 0.04, green: 0.43, blue: 0.38, alpha: 1)
backdrop.setFill()
NSBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: height)).fill()

func text(_ string: String, top: CGFloat, size: CGFloat, weight: NSFont.Weight, color: NSColor) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    (string as NSString).draw(in: CGRect(x: 30, y: height - top - 45, width: width - 60, height: 45),
                             withAttributes: [.font: NSFont.systemFont(ofSize: size, weight: weight),
                                              .foregroundColor: color, .paragraphStyle: paragraph])
}
text("Install Transflo", top: 24, size: 32, weight: .semibold, color: ink)
text("Drag Transflo to Applications to get started.", top: 70, size: 15, weight: .regular, color: muted)

// Finder places the two real, draggable icons on either side of this arrow.
teal.setStroke()
let arrow = NSBezierPath()
arrow.lineWidth = 2.5
arrow.lineCapStyle = .round
arrow.lineJoinStyle = .round
let arrowY = height - 175
arrow.move(to: CGPoint(x: 282, y: arrowY))
arrow.line(to: CGPoint(x: 358, y: arrowY))
arrow.move(to: CGPoint(x: 346, y: arrowY + 10))
arrow.line(to: CGPoint(x: 358, y: arrowY))
arrow.line(to: CGPoint(x: 346, y: arrowY - 10))
arrow.stroke()
text("Then open Transflo from Applications.", top: 278, size: 13, weight: .regular, color: muted)
NSGraphicsContext.restoreGraphicsState()
guard let data = bitmap.representation(using: .png, properties: [:]) else { exit(1) }
try data.write(to: output)
