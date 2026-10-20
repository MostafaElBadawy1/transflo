import AVFoundation

/// Plays Russian Roulette's sounds.
protocol RouletteSoundPlaying {
    func preload()
    func play(_ sound: RouletteSound)
}

/// Preloaded players through the default output, so system volume and mute apply.
///
/// The click gets several voices: a fast turn starts a click before the last one ends, and
/// restarting a single player would cut it off. A missing file stays silent.
final class RouletteSoundBank: RouletteSoundPlaying {
    private static let clickVoices = 3
    private static let volumes: [RouletteSound: Float] = [
        .cylinderClick: 0.45, .cylinderLock: 0.6, .gunshot: 0.7, .emptyClick: 0.6
    ]

    private let bundle: Bundle
    private var voices: [RouletteSound: [AVAudioPlayer]] = [:]
    private var nextVoice: [RouletteSound: Int] = [:]
    private var isLoaded = false

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func preload() {
        guard !isLoaded else { return }
        isLoaded = true
        for sound in RouletteSound.allCases {
            guard let url = bundle.url(forResource: sound.rawValue, withExtension: "wav") else { continue }
            let count = sound == .cylinderClick ? Self.clickVoices : 1
            voices[sound] = (0..<count).compactMap { _ in
                let player = try? AVAudioPlayer(contentsOf: url)
                player?.volume = Self.volumes[sound] ?? 0.6
                player?.prepareToPlay()
                return player
            }
        }
    }

    func play(_ sound: RouletteSound) {
        preload()
        guard let players = voices[sound], !players.isEmpty else { return }
        let index = nextVoice[sound, default: 0] % players.count
        nextVoice[sound] = index + 1
        let player = players[index]
        player.currentTime = 0
        player.play()
    }
}
