/// Color adjustments: exposure in stops (−2…2), contrast and saturation as multipliers.
public struct ImageAdjustments: Sendable, Hashable {
    public static let exposureRange = -2.0...2.0
    public static let contrastRange = 0.5...1.5
    public static let saturationRange = 0.0...2.0
    public static let neutral = ImageAdjustments(exposure: 0, contrast: 1, saturation: 1)

    public let exposure: Double
    public let contrast: Double
    public let saturation: Double

    public init(exposure: Double, contrast: Double, saturation: Double) {
        self.exposure = exposure.clamped(to: Self.exposureRange)
        self.contrast = contrast.clamped(to: Self.contrastRange)
        self.saturation = saturation.clamped(to: Self.saturationRange)
    }

    public var isNeutral: Bool {
        self == .neutral
    }
}

extension Double {
    /// The value limited to `range`.
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
