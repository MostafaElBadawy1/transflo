/// Persisted visual preferences, independent of any UI framework.
public struct InterfaceCustomization: Sendable, Equatable, Codable {
    public enum WheelSize: String, Sendable, Codable, CaseIterable {
        case compact, standard, large

        public var scale: Double {
            switch self {
            case .compact: 0.9
            case .standard: 1
            case .large: 1.15
            }
        }
    }

    /// Six RGB hex digits, or nil for Transflo's original adaptive accent.
    public var accentHex: String?
    public var wheelSize: WheelSize
    public var solidSurfaces: Bool
    public var reduceMotion: Bool

    public init(
        accentHex: String? = nil,
        wheelSize: WheelSize = .standard,
        solidSurfaces: Bool = false,
        reduceMotion: Bool = false
    ) {
        self.accentHex = Self.validatedHex(accentHex)
        self.wheelSize = wheelSize
        self.solidSurfaces = solidSurfaces
        self.reduceMotion = reduceMotion
    }

    public static let standard = InterfaceCustomization()

    public static func validatedHex(_ value: String?) -> String? {
        guard let value, value.count == 6, value.utf8.allSatisfy({
            (48...57).contains($0) || (65...70).contains($0) || (97...102).contains($0)
        }) else { return nil }
        return value.uppercased()
    }

    /// Validate decoded and edited preferences at the storage/application boundary.
    public var validated: Self {
        Self(accentHex: accentHex, wheelSize: wheelSize, solidSurfaces: solidSurfaces, reduceMotion: reduceMotion)
    }
}
