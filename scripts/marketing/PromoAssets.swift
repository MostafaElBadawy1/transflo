import AppKit

/// Repository over the README screenshots the video is built from.
struct PromoAssets {
    enum AssetError: Error, CustomStringConvertible {
        case missing(String)
        case unreadable(String)

        var description: String {
            switch self {
            case .missing(let path): "missing screenshot: \(path)"
            case .unreadable(let name): "could not crop \(name)"
            }
        }
    }

    private let folder: URL

    init(folder: URL) {
        self.folder = folder
    }

    func image(_ name: String) throws -> NSImage {
        let url = folder.appendingPathComponent(name).appendingPathExtension("png")
        guard let image = NSImage(contentsOf: url) else { throw AssetError.missing(url.path) }
        return image
    }

    /// A region of a screenshot, in pixels from its top-left corner.
    func region(_ name: String, rect: CGRect) throws -> NSImage {
        guard let cgImage = try image(name).cgImage(forProposedRect: nil, context: nil, hints: nil),
              let cropped = cgImage.cropping(to: rect) else { throw AssetError.unreadable(name) }
        return NSImage(cgImage: cropped, size: rect.size)
    }

    /// The wheel inside a square wheel screenshot, cropped to the square around its circle.
    /// - Parameter radiusFraction: The wheel's radius as a share of the screenshot's width. The wheel
    ///   keeps the same share of its panel at any capture size, so this survives re-captures.
    func wheel(_ name: String, radiusFraction: CGFloat) throws -> NSImage {
        guard let cgImage = try image(name).cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw AssetError.unreadable(name)
        }
        let radius = CGFloat(cgImage.width) * radiusFraction
        let rect = CGRect(x: CGFloat(cgImage.width) / 2 - radius, y: CGFloat(cgImage.height) / 2 - radius,
                          width: radius * 2, height: radius * 2).integral
        guard let cropped = cgImage.cropping(to: rect) else { throw AssetError.unreadable(name) }
        return NSImage(cgImage: cropped, size: rect.size)
    }
}
