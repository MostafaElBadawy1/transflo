import AppKit
import Foundation
import Testing
@testable import Transflo

@Suite("Roulette feedback")
struct RouletteFeedbackTests {
    private final class SpySounds: RouletteSoundPlaying {
        var preloads = 0
        var played: [RouletteSound] = []

        func preload() {
            preloads += 1
        }

        func play(_ sound: RouletteSound) {
            played.append(sound)
        }
    }

    private final class SpyHaptics {
        var patterns: [NSHapticFeedbackManager.FeedbackPattern] = []
    }

    private struct Harness {
        let sounds: SpySounds
        let haptics: SpyHaptics
        let sut: RouletteFeedback
        var patterns: [NSHapticFeedbackManager.FeedbackPattern] { haptics.patterns }

        init(muted: Bool = false, haptics enabled: Bool = true, roll: Int = 1) {
            let sounds = SpySounds()
            let haptics = SpyHaptics()
            self.sounds = sounds
            self.haptics = haptics
            sut = RouletteFeedback(isMuted: { muted }, isHapticsEnabled: { enabled }, sounds: sounds,
                                   haptic: { haptics.patterns.append($0) }, random: { _ in roll }, sleep: { _ in })
        }
    }

    @Test("a turn plays one click per chamber, spaced out, then the lock")
    func beats() {
        #expect(RouletteFeedback.beats(forSteps: 0).isEmpty)
        let three = RouletteFeedback.beats(forSteps: -3)
        #expect(three.map(\.sound) == [.cylinderClick, .cylinderClick, .cylinderClick, .cylinderLock])
        #expect(three.map(\.delay) == [.zero, RouletteFeedback.clickSpacing, RouletteFeedback.clickSpacing,
                                       RouletteFeedback.lockDelay])
    }

    @Test("one chamber in n is loaded", arguments: [6, 7, 12])
    func odds(chambers: Int) {
        let outcomes = (0..<chambers).map { roll in RouletteOutcome.roll(chamberCount: chambers) { _ in roll } }
        #expect(outcomes.filter { $0 == .hit }.count == 1)
        #expect(RouletteOutcome.roll(chamberCount: 0) { bound in bound - 1 } == .hit)
    }

    @Test("turning plays the sequence with trackpad feedback on every click")
    func turned() async {
        let harness = Harness()
        harness.sut.turned(steps: 2)
        await settle()
        #expect(harness.sounds.played == [.cylinderClick, .cylinderClick, .cylinderLock])
        #expect(harness.patterns == [.alignment, .alignment, .levelChange])
    }

    @Test("a new turn replaces what is left of the previous one")
    func replaced() async {
        let harness = Harness()
        harness.sut.turned(steps: 4)
        harness.sut.turned(steps: 1)
        await settle()
        #expect(harness.sounds.played == [.cylinderClick, .cylinderLock])
    }

    @Test("firing plays the gunshot on a hit and the dry click on a miss", arguments: [
        (0, RouletteOutcome.hit, RouletteSound.gunshot), (3, .miss, .emptyClick)
    ])
    func fire(roll: Int, outcome: RouletteOutcome, sound: RouletteSound) {
        let harness = Harness(roll: roll)
        #expect(harness.sut.fire(chamberCount: 6) == outcome)
        #expect(harness.sounds.played == [sound])
        #expect(harness.patterns == [.levelChange])
    }

    @Test("mute silences sounds but keeps haptics; the haptics preference turns those off")
    func preferences() {
        let muted = Harness(muted: true)
        _ = muted.sut.fire(chamberCount: 6)
        #expect(muted.sounds.played.isEmpty && muted.patterns.count == 1)
        let still = Harness(haptics: false)
        _ = still.sut.fire(chamberCount: 6)
        #expect(still.sounds.played.count == 1 && still.patterns.isEmpty)
    }

    @Test("prepare preloads the sounds")
    func prepare() {
        let harness = Harness()
        harness.sut.prepare()
        #expect(harness.sounds.preloads == 1)
    }

    @Test("every roulette sound is packaged with the application", arguments: RouletteSound.allCases)
    func packaged(sound: RouletteSound) throws {
        let url = try #require(Bundle.main.url(forResource: sound.rawValue, withExtension: "wav"))
        let data = try Data(contentsOf: url)
        #expect(data.prefix(4) == Data("RIFF".utf8))
        #expect(data.count > 44)
    }

    /// Lets the sequence task run to the end (its sleeps return at once).
    private func settle() async {
        for _ in 0..<10 { await Task.yield() }
    }
}
