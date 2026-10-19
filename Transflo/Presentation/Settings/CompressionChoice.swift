import TransfloDomain

/// The four choices shown in instant-tool preferences.
enum CompressionChoice: Hashable {
    case light, medium, strong, target

    init(_ goal: CompressionGoal) {
        switch goal {
        case .level(.light): self = .light
        case .level(.medium): self = .medium
        case .level(.strong): self = .strong
        case .targetBytes: self = .target
        }
    }

    func goal(megabytes: Double) -> CompressionGoal {
        switch self {
        case .light: .level(.light)
        case .medium: .level(.medium)
        case .strong: .level(.strong)
        case .target: .targetBytes(Int64(megabytes * 1_000_000))
        }
    }
}
