import AppKit

/// A headline with real screenshots that slide in and drift slowly while the scene plays.
struct ShowcaseScene: PromoScene {
    enum Layout {
        /// Text in a left column, screenshots on the right.
        case textLeft
        /// Centered text above the screenshots.
        case textTop
    }

    struct Shot {
        let image: NSImage
        let frame: CGRect
        var delay = 0.0
    }

    let eyebrow: String
    let headline: String
    let detail: String
    let shots: [Shot]
    var layout = Layout.textLeft
    var duration = 5.0

    func draw(on canvas: PromoCanvas, at time: Double) {
        for shot in shots {
            let amount = PromoEasing.outCubic(PromoEasing.progress(time, from: 0.2 + shot.delay, to: 0.9 + shot.delay))
            let drift = PromoEasing.mix(1, 1.035, PromoEasing.progress(time, from: 0, to: duration))
            let center = CGPoint(x: shot.frame.midX, y: shot.frame.midY)
            canvas.layer(alpha: amount) {
                canvas.transformed(scale: PromoEasing.mix(0.96, 1, amount) * drift, around: center,
                                   offset: CGSize(width: 0, height: (1 - amount) * 50)) {
                    canvas.image(shot.image, in: Self.fitted(shot.image.size, in: shot.frame))
                }
            }
        }
        switch layout {
        case .textLeft: drawTextColumn(on: canvas, at: time)
        case .textTop: drawTextHeader(on: canvas, at: time)
        }
    }

    /// The largest rect with `size`'s proportions centered in `frame`, so a re-captured screenshot
    /// with a different shape is never stretched.
    static func fitted(_ size: CGSize, in frame: CGRect) -> CGRect {
        guard size.width > 0, size.height > 0 else { return frame }
        let scale = min(frame.width / size.width, frame.height / size.height)
        let fitted = CGSize(width: size.width * scale, height: size.height * scale)
        return CGRect(x: frame.midX - fitted.width / 2, y: frame.midY - fitted.height / 2,
                      width: fitted.width, height: fitted.height)
    }

    private func drawTextColumn(on canvas: PromoCanvas, at time: Double) {
        let left: CGFloat = 140
        let width: CGFloat = 660
        canvas.reveal(at: time, start: 0) {
            canvas.paragraph(eyebrow.uppercased(), origin: CGPoint(x: left, y: 360), width: width, style: .eyebrow)
        }
        var top: CGFloat = 410
        canvas.reveal(at: time, start: 0.15) {
            top += canvas.paragraph(headline, origin: CGPoint(x: left, y: top), width: width, style: .headline)
        }
        canvas.reveal(at: time, start: 0.35) {
            canvas.paragraph(detail, origin: CGPoint(x: left, y: top + 28), width: width, style: .body)
        }
    }

    private func drawTextHeader(on canvas: PromoCanvas, at time: Double) {
        canvas.reveal(at: time, start: 0) {
            canvas.text(headline, center: CGPoint(x: 960, y: 130), style: .headline)
        }
        canvas.reveal(at: time, start: 0.2) {
            canvas.text(detail, center: CGPoint(x: 960, y: 210), style: .body)
        }
    }
}
