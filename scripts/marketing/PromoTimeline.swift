/// Composite of scenes played back to back. Each transition dips through the backdrop: the outgoing
/// scene fades out in the first half of the overlap and the next fades in during the second half.
struct PromoTimeline {
    private let scenes: [any PromoScene]
    private let crossfade: Double

    init(scenes: [any PromoScene], crossfade: Double) {
        self.scenes = scenes
        self.crossfade = crossfade
    }

    var duration: Double {
        scenes.reduce(0) { $0 + $1.duration } - crossfade * Double(max(0, scenes.count - 1))
    }

    func draw(on canvas: PromoCanvas, at time: Double) {
        canvas.backdrop()
        var start = 0.0
        for (index, scene) in scenes.enumerated() {
            let local = time - start
            if local >= 0, local <= scene.duration {
                let half = crossfade / 2
                let fadeIn = index == 0
                    ? PromoEasing.progress(local, from: 0, to: 0.4)
                    : PromoEasing.progress(local, from: half, to: crossfade)
                let isLast = index == scenes.count - 1
                let fadeOut = isLast ? 1 : 1 - PromoEasing.progress(local, from: scene.duration - crossfade,
                                                                    to: scene.duration - half)
                canvas.layer(alpha: min(fadeIn, fadeOut)) { scene.draw(on: canvas, at: local) }
            }
            start += scene.duration - crossfade
        }
    }
}
