/// Canvas shapes for image presentation, without cropping the source picture.
public enum BackgroundCanvasRatio: Sendable, Hashable, CaseIterable {
    case automatic, square, sixteenNine, fourFive, nineSixteen

    public var ratio: Double? {
        switch self {
        case .automatic: nil
        case .square: 1
        case .sixteenNine: 16.0 / 9.0
        case .fourFive: 4.0 / 5.0
        case .nineSixteen: 9.0 / 16.0
        }
    }
}
