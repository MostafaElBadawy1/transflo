@testable import Transflo

/// Records trigger pulls and answers with a fixed outcome.
final class SpyRouletteFiring: RouletteFiring {
    var outcome = RouletteOutcome.miss
    private(set) var prepareCount = 0
    private(set) var firedChamberCounts: [Int] = []

    func prepare() {
        prepareCount += 1
    }

    func fire(chamberCount: Int) -> RouletteOutcome {
        firedChamberCounts.append(chamberCount)
        return outcome
    }
}
