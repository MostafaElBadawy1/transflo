import AppKit

/// Brand values mirrored from the asset catalog's dark appearance and the app icon.
enum PromoPalette {
    static let inkTop = rgb(0x24282B)
    static let inkBottom = rgb(0x121416)
    static let accent = rgb(0x3FB8A5)
    static let textPrimary = rgb(0xEDEBE6)
    static let textSecondary = rgb(0x9FA6A8)
    static let paper = rgb(0xF6F4EF)
    static let paperEdge = rgb(0xCFCBC2)
    static let ink = rgb(0x1B1D1F)
    static let pill = rgb(0x2C3135)
    /// The result disc's recessed well and empty progress track, as in the app's dark appearance.
    static let well = rgb(0x1E2326)
    static let track = rgb(0x3A4044)
    /// Finder's selection color, so the dragged file reads as a Finder item.
    static let finderSelection = rgb(0x2C6FE4)
    static let sky = rgb(0xBFE6DD)
    static let sun = rgb(0xF2C14E)
    static let hill = rgb(0x2F7D6E)
    static let shadow = NSColor(white: 0, alpha: 0.45)

    static func rgb(_ hex: Int) -> NSColor {
        NSColor(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
