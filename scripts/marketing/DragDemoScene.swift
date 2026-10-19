import AppKit

/// The core gesture: drag a photo, tap ⇧, drop on JPG. The wheel folds into the result disc, which
/// fills and ticks, and the copy appears beside the original.
struct DragDemoScene: PromoScene {
    let wheel: NSImage
    let duration = 8.6

    private let discDiameter: CGFloat = 190

    private let wheelCenter = CGPoint(x: 960, y: 590)
    private let wheelDiameter: CGFloat = 600
    /// The JPG petal, as an offset from the wheel center measured on the 648-px-wide convert wheel crop.
    private var petal: CGPoint {
        let scale = wheelDiameter / 648
        return CGPoint(x: wheelCenter.x + 174 * scale, y: wheelCenter.y - 139 * scale)
    }

    func draw(on canvas: PromoCanvas, at time: Double) {
        let headlineIn = PromoEasing.progress(time, from: 0, to: 0.5)
        canvas.layer(alpha: headlineIn) {
            canvas.text("Drag a file. Tap a key. Drop.", center: CGPoint(x: 960, y: 140), style: .headline)
        }
        drawWheel(on: canvas, at: time)
        drawKeycap(on: canvas, at: time)
        drawDrag(on: canvas, at: time)
        drawResult(on: canvas, at: time)
    }

    private func drawWheel(on canvas: PromoCanvas, at time: Double) {
        let appear = PromoEasing.progress(time, from: 2.15, to: 2.6)
        // After the drop the wheel folds into its hub, where the result disc takes over.
        let leave = PromoEasing.inOutCubic(PromoEasing.progress(time, from: 3.95, to: 4.45))
        let scale = PromoEasing.mix(0.82, 1, PromoEasing.outBack(appear))
            * PromoEasing.mix(1, discDiameter / wheelDiameter, leave)
        canvas.layer(alpha: min(PromoEasing.progress(time, from: 2.15, to: 2.4), 1 - leave)) {
            canvas.transformed(scale: scale, around: wheelCenter) {
                canvas.circle(wheel, center: wheelCenter, diameter: wheelDiameter)
            }
        }
    }

    private func drawKeycap(on canvas: PromoCanvas, at time: Double) {
        let pop = PromoEasing.outBack(PromoEasing.progress(time, from: 1.8, to: 2.15))
        let press = PromoEasing.progress(time, from: 2.15, to: 2.25) - PromoEasing.progress(time, from: 2.25, to: 2.4)
        let leave = PromoEasing.progress(time, from: 3.9, to: 4.2)
        let center = CGPoint(x: 960, y: 970)
        canvas.layer(alpha: min(PromoEasing.progress(time, from: 1.8, to: 1.95), 1 - leave)) {
            canvas.transformed(scale: pop * (1 - press * 0.08), around: center) {
                canvas.keycap("⇧", center: center, side: 96)
            }
        }
    }

    private func drawDrag(on canvas: PromoCanvas, at time: Double) {
        let start = CGPoint(x: 330, y: 620)
        let approach = PromoEasing.inOutCubic(PromoEasing.progress(time, from: 0.4, to: 1.8))
        let aim = PromoEasing.inOutCubic(PromoEasing.progress(time, from: 2.6, to: 3.5))
        var point = CGPoint(x: PromoEasing.mix(start.x, wheelCenter.x, approach),
                            y: PromoEasing.mix(start.y, wheelCenter.y, approach))
        point.x = PromoEasing.mix(point.x, petal.x, aim)
        point.y = PromoEasing.mix(point.y, petal.y, aim)
        let drop = PromoEasing.progress(time, from: 3.8, to: 4.1)
        canvas.layer(alpha: PromoEasing.progress(time, from: 0, to: 0.4) * (1 - drop)) {
            canvas.transformed(scale: PromoEasing.mix(1, 0.4, drop), around: point) {
                canvas.layer(alpha: 0.88) {
                    PromoFileCard(name: "Holiday photo.heic").draw(on: canvas, center: point)
                }
            }
        }
        let pointerAway = PromoEasing.progress(time, from: 4.2, to: 4.5)
        canvas.layer(alpha: PromoEasing.progress(time, from: 0, to: 0.4) * (1 - pointerAway)) {
            canvas.cursor(at: CGPoint(x: point.x + 6, y: point.y + 6))
        }
    }

    private func drawResult(on canvas: PromoCanvas, at time: Double) {
        let enter = PromoEasing.outCubic(PromoEasing.progress(time, from: 4.1, to: 4.5))
        let leave = PromoEasing.inOutCubic(PromoEasing.progress(time, from: 6.5, to: 6.9))
        let pulse = sin(Double.pi * PromoEasing.progress(time, from: 5.9, to: 6.25)) * 0.08
        let scale = PromoEasing.mix(1.4, 1, enter) * (1 + pulse) * PromoEasing.mix(1, 0.6, leave)
        canvas.layer(alpha: enter * (1 - leave)) {
            canvas.transformed(scale: scale, around: wheelCenter) {
                PromoResultDisc(diameter: discDiameter).draw(
                    on: canvas, center: wheelCenter,
                    progress: PromoEasing.inOutCubic(PromoEasing.progress(time, from: 4.5, to: 5.5)),
                    tick: PromoEasing.outCubic(PromoEasing.progress(time, from: 5.55, to: 5.95))
                )
            }
        }
        let original = PromoEasing.progress(time, from: 6.7, to: 7.05)
        canvas.layer(alpha: original) {
            PromoFileCard(name: "Holiday photo.heic").draw(on: canvas, center: CGPoint(x: 820, y: 590))
        }
        let copy = PromoEasing.progress(time, from: 6.95, to: 7.4)
        let copyCenter = CGPoint(x: 1100, y: 590)
        canvas.layer(alpha: PromoEasing.progress(time, from: 6.95, to: 7.1)) {
            canvas.transformed(scale: PromoEasing.outBack(copy), around: copyCenter) {
                PromoFileCard(name: "Holiday photo.jpg").draw(on: canvas, center: copyCenter)
            }
        }
        let doneLine = PromoEasing.progress(time, from: 5.6, to: 6.0) - PromoEasing.progress(time, from: 6.5, to: 6.8)
        canvas.layer(alpha: doneLine) {
            canvas.text("Done. Click the disc to show it in Finder.", center: CGPoint(x: 960, y: 870), style: .body)
        }
        canvas.layer(alpha: PromoEasing.progress(time, from: 7.1, to: 7.6)) {
            canvas.text("Saved next to the original. Nothing leaves your Mac.",
                        center: CGPoint(x: 960, y: 225), style: .body)
        }
    }
}
