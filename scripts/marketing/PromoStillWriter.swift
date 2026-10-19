import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Writes one frame as a PNG, for reviewing scenes and for the README poster.
struct PromoStillWriter {
    enum StillError: Error, CustomStringConvertible {
        case render
        case write(String)

        var description: String {
            switch self {
            case .render: "could not render the still"
            case .write(let path): "could not write \(path)"
            }
        }
    }

    let size: CGSize

    func write(to output: URL, draw: (CGContext) -> Void) throws {
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else { throw StillError.render }
        draw(context)
        guard let image = context.makeImage() else { throw StillError.render }
        guard let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString,
                                                                1, nil) else { throw StillError.write(output.path) }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw StillError.write(output.path) }
    }
}
