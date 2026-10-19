import Foundation

/// Easing curves and clamped progress used by every scene.
enum PromoEasing {
    /// 0 before `start`, 1 after `end`, linear in between.
    static func progress(_ time: Double, from start: Double, to end: Double) -> Double {
        guard end > start else { return time >= end ? 1 : 0 }
        return min(1, max(0, (time - start) / (end - start)))
    }

    static func outCubic(_ value: Double) -> Double { 1 - pow(1 - value, 3) }

    static func inOutCubic(_ value: Double) -> Double {
        value < 0.5 ? 4 * value * value * value : 1 - pow(-2 * value + 2, 3) / 2
    }

    /// Overshoots slightly before settling, for things that pop in.
    static func outBack(_ value: Double) -> Double {
        let overshoot = 1.70158
        let shifted = value - 1
        return 1 + (overshoot + 1) * pow(shifted, 3) + overshoot * pow(shifted, 2)
    }

    static func mix(_ from: Double, _ to: Double, _ amount: Double) -> Double { from + (to - from) * amount }
}
