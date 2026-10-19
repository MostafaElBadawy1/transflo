import AppKit

/// Convert, Tools and Actions side by side, each with the key that opens it.
struct WheelTrioScene: PromoScene {
    struct Wheel {
        let image: NSImage
        let key: String
        let title: String
        let detail: String
    }

    let wheels: [Wheel]
    let duration = 5.6

    func draw(on canvas: PromoCanvas, at time: Double) {
        canvas.layer(alpha: PromoEasing.progress(time, from: 0, to: 0.5)) {
            canvas.text("Three wheels. One gesture.", center: CGPoint(x: 960, y: 130), style: .headline)
        }
        let spacing: CGFloat = 560
        let firstX = canvas.size.width / 2 - spacing * CGFloat(wheels.count - 1) / 2
        for (index, wheel) in wheels.enumerated() {
            let start = 0.25 + Double(index) * 0.3
            let amount = PromoEasing.progress(time, from: start, to: start + 0.6)
            let centerX = firstX + spacing * CGFloat(index)
            let circleCenter = CGPoint(x: centerX, y: 480)
            canvas.layer(alpha: PromoEasing.progress(time, from: start, to: start + 0.3)) {
                canvas.transformed(scale: PromoEasing.mix(0.85, 1, PromoEasing.outBack(amount)), around: circleCenter) {
                    canvas.circle(wheel.image, center: circleCenter, diameter: 440)
                }
                let keyCenter = CGPoint(x: centerX, y: 790)
                canvas.transformed(scale: PromoEasing.outBack(amount), around: keyCenter) {
                    canvas.keycap(wheel.key, center: keyCenter, side: 80)
                }
                canvas.text(wheel.title, center: CGPoint(x: centerX, y: 885), style: .label)
                canvas.text(wheel.detail, center: CGPoint(x: centerX, y: 932), style: .caption)
            }
        }
    }
}
