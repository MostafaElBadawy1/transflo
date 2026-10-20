import AppKit

/// Russian Roulette's sounds, bundled as WAV files named after the raw value.
nonisolated enum RouletteSound: String, CaseIterable {
    case cylinderClick = "cylinder_click"
    case cylinderLock = "cylinder_lock"
    case gunshot
    case emptyClick = "empty_click"

    /// The trackpad pattern felt with the sound: light for the ratchet, firmer for the rest.
    var hapticPattern: NSHapticFeedbackManager.FeedbackPattern {
        self == .cylinderClick ? .alignment : .levelChange
    }
}

/// What pulling the trigger did. Either way the job runs exactly as without the mode.
nonisolated enum RouletteOutcome: Equatable {
    case hit, miss

    /// One chamber in `chamberCount` is loaded: `random(n)` returns a value in `0..<n`, and 0 hits.
    static func roll(chamberCount: Int, random: (Int) -> Int) -> Self {
        random(max(chamberCount, 1)) == 0 ? .hit : .miss
    }
}

/// The trigger the wheel pulls on a drop in Russian Roulette mode.
protocol RouletteFiring: AnyObject {
    /// Loads the sounds ahead of their first use.
    func prepare()
    /// Rolls the outcome and plays it without waiting for the sound.
    func fire(chamberCount: Int) -> RouletteOutcome
}

/// Sounds and trackpad feedback for Russian Roulette mode.
///
/// A turn of several chambers plays one ratchet click per chamber, spaced out so they don't blur,
/// then the heavier lock. A new turn cancels what is left of the previous one, so fast hovering
/// never queues up. Nothing here blocks: sounds are preloaded and played asynchronously.
final class RouletteFeedback: RouletteFiring {
    /// One sound in a turn's sequence and its delay after the previous one.
    struct Beat: Equatable {
        let delay: Duration
        let sound: RouletteSound
    }

    static let shared = RouletteFeedback()
    static let clickSpacing: Duration = .milliseconds(45)
    /// The lock lands as the turn settles.
    static let lockDelay: Duration = .milliseconds(70)

    private let isMuted: () -> Bool
    private let isHapticsEnabled: () -> Bool
    private let sounds: any RouletteSoundPlaying
    private let haptic: (NSHapticFeedbackManager.FeedbackPattern) -> Void
    private let random: (Int) -> Int
    private let sleep: (Duration) async -> Void
    private var sequence: Task<Void, Never>?

    init(
        isMuted: @escaping () -> Bool = { InterfaceStyle.shared.preferences.rouletteSoundsMuted },
        isHapticsEnabled: @escaping () -> Bool = { InterfaceStyle.shared.preferences.wheelHaptics },
        sounds: any RouletteSoundPlaying = RouletteSoundBank(),
        haptic: @escaping (NSHapticFeedbackManager.FeedbackPattern) -> Void = { pattern in
            NSHapticFeedbackManager.defaultPerformer.perform(pattern, performanceTime: .now)
        },
        random: @escaping (Int) -> Int = { Int.random(in: 0..<$0) },
        sleep: @escaping (Duration) async -> Void = { try? await Task.sleep(for: $0) }
    ) {
        self.isMuted = isMuted
        self.isHapticsEnabled = isHapticsEnabled
        self.sounds = sounds
        self.haptic = haptic
        self.random = random
        self.sleep = sleep
    }

    /// The clicks and lock for a turn of `steps` chambers (either direction); none for no turn.
    static func beats(forSteps steps: Int) -> [Beat] {
        let count = abs(steps)
        guard count > 0 else { return [] }
        let clicks = (0..<count).map { Beat(delay: $0 == 0 ? .zero : clickSpacing, sound: .cylinderClick) }
        return clicks + [Beat(delay: lockDelay, sound: .cylinderLock)]
    }

    func prepare() {
        sounds.preload()
    }

    /// The cylinder turned by `steps` chambers.
    func turned(steps: Int) {
        sequence?.cancel()
        let beats = Self.beats(forSteps: steps)
        guard !beats.isEmpty else { return }
        sequence = Task { [weak self] in
            for beat in beats {
                guard let self else { return }
                if beat.delay > .zero { await sleep(beat.delay) }
                guard !Task.isCancelled else { return }
                emit(beat.sound)
            }
        }
    }

    func fire(chamberCount: Int) -> RouletteOutcome {
        sequence?.cancel()
        let outcome = RouletteOutcome.roll(chamberCount: chamberCount, random: random)
        emit(outcome == .hit ? .gunshot : .emptyClick)
        return outcome
    }

    private func emit(_ sound: RouletteSound) {
        if isHapticsEnabled() { haptic(sound.hapticPattern) }
        if !isMuted() { sounds.play(sound) }
    }
}
