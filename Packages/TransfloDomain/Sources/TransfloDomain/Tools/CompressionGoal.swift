/// Strategy selection for either a quality preset or an upper bound on output bytes.
public enum CompressionGoal: Sendable, Hashable, Codable {
    case level(CompressionLevel)
    case targetBytes(Int64)

    // Source-compatible spellings for existing preset callers.
    public static let light = CompressionGoal.level(.light)
    public static let medium = CompressionGoal.level(.medium)
    public static let strong = CompressionGoal.level(.strong)
}
