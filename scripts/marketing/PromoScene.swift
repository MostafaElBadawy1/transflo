/// One self-timed part of the video. `time` runs from 0 to `duration`.
protocol PromoScene {
    var duration: Double { get }
    func draw(on canvas: PromoCanvas, at time: Double)
}
