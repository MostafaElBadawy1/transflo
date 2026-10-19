import AppKit

/// Opening card: the icon pops in, then the name and tagline rise into place.
struct TitleScene: PromoScene {
    let icon: NSImage
    let duration = 4.0

    func draw(on canvas: PromoCanvas, at time: Double) {
        let midX = canvas.size.width / 2
        let iconIn = PromoEasing.progress(time, from: 0, to: 0.8)
        canvas.layer(alpha: PromoEasing.progress(time, from: 0, to: 0.4)) {
            let center = CGPoint(x: midX, y: 380)
            canvas.transformed(scale: PromoEasing.mix(0.7, 1, PromoEasing.outBack(iconIn)), around: center) {
                canvas.image(icon, in: CGRect(x: center.x - 140, y: center.y - 140, width: 280, height: 280))
            }
        }
        canvas.reveal(at: time, start: 0.35, distance: 30) {
            canvas.text("Transflo", center: CGPoint(x: midX, y: 600), style: .display)
        }
        canvas.reveal(at: time, start: 0.65) {
            let style = PromoTextStyle(size: 40, weight: .regular, color: PromoPalette.textSecondary)
            canvas.text("Convert, edit and share files from a wheel at your cursor.",
                        center: CGPoint(x: midX, y: 700), style: style)
        }
        canvas.reveal(at: time, start: 1.0) {
            canvas.text("FREE AND OPEN SOURCE FOR MACOS", center: CGPoint(x: midX, y: 775), style: .eyebrow)
        }
    }
}
