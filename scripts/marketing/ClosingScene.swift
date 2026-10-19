import AppKit

/// Closing card: how to get Transflo.
struct ClosingScene: PromoScene {
    let icon: NSImage
    let duration = 5.0

    func draw(on canvas: PromoCanvas, at time: Double) {
        let midX = canvas.size.width / 2
        let iconIn = PromoEasing.progress(time, from: 0, to: 0.7)
        let iconCenter = CGPoint(x: midX, y: 300)
        canvas.layer(alpha: iconIn) {
            canvas.transformed(scale: PromoEasing.mix(0.8, 1, PromoEasing.outBack(iconIn)), around: iconCenter) {
                canvas.image(icon, in: CGRect(x: iconCenter.x - 110, y: iconCenter.y - 110, width: 220, height: 220))
            }
        }
        canvas.reveal(at: time, start: 0.3) {
            canvas.text("Free and open source.", center: CGPoint(x: midX, y: 500), style: .headline)
        }
        canvas.reveal(at: time, start: 0.6) {
            let command = "brew install --cask ali-fayed/transflo/transflo"
            let attributes = PromoTextStyle.code.attributes(alignment: .center)
            let attributed = NSAttributedString(string: command, attributes: attributes)
            let width = attributed.size().width + 64
            canvas.capsule(CGRect(x: midX - width / 2, y: 572, width: width, height: 76), color: PromoPalette.pill)
            canvas.text(command, center: CGPoint(x: midX, y: 610), style: .code)
        }
        canvas.reveal(at: time, start: 0.9) {
            let link = PromoTextStyle(size: 32, weight: .semibold, color: PromoPalette.accent)
            canvas.text("github.com/Ali-Fayed/transflo", center: CGPoint(x: midX, y: 712), style: link)
            canvas.text("macOS 14 or later · Apple silicon", center: CGPoint(x: midX, y: 770), style: .caption)
            canvas.text("DMG · Homebrew · Mac App Store (coming soon)", center: CGPoint(x: midX, y: 812),
                        style: .caption)
        }
    }
}
