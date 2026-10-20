/// How the wheel plays Russian Roulette mode: whether the mode is on when a wheel opens, how long
/// the pointer must rest on a chamber to aim it, and what to do when the cylinder turns.
struct WheelRoulette {
    let isEnabled: () -> Bool
    var aimDelay: Duration = .milliseconds(150)
    /// Called with the signed chamber steps of each turn.
    var onTurn: (Int) -> Void = { _ in }

    static let off = WheelRoulette(isEnabled: { false })
}
