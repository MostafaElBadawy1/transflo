#if DEBUG
import AppKit
import CoreText
import ImageIO
import TransfloDomain

/// Scratch inputs for the debug-only preview launch arguments (UI-test screenshots).
///
/// Nonisolated so callers write the files off the main thread (ImageIO warns about HEIC
/// encoding there); see `inBackground`.
nonisolated enum PreviewScratchFiles {
    static let pageCount = 4
    static let imageCount = 4

    /// `make(for:in:)` on a background thread, creating `folder` first.
    static func inBackground(for tool: ToolKind, in folder: URL) async -> [URL] {
        await Task.detached(priority: .userInitiated) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            return make(for: tool, in: folder)
        }.value
    }

    /// A PDF for page tools, several images for multi-file tools, one image otherwise.
    static func make(for tool: ToolKind, in folder: URL) -> [URL] {
        switch tool {
        case .reorganizePages, .extractPages:
            let pdf = folder.appendingPathComponent("Quarterly report.pdf")
            writePDF(to: pdf)
            return [pdf]
        case .collage, .rename:
            return (1...imageCount).map { index in
                let url = folder.appendingPathComponent("Holiday photo \(index).heic")
                writeHEIC(to: url)
                return url
            }
        default:
            let url = folder.appendingPathComponent("Holiday photo.heic")
            writeHEIC(to: url)
            return [url]
        }
    }

    /// A 640×480 picture: a teal disc on a transparent background.
    static func writeHEIC(to url: URL) {
        let context = CGContext(
            data: nil, width: 640, height: 480, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.setFillColor(CGColor(red: 0.07, green: 0.65, blue: 0.58, alpha: 1))
        context?.fillEllipse(in: CGRect(x: 170, y: 90, width: 300, height: 300))
        guard let image = context?.makeImage(),
              let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.heic" as CFString, 1, nil)
        else { return }
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }

    /// Letter-size pages, each showing its number.
    private static func writePDF(to url: URL) {
        var box = CGRect(x: 0, y: 0, width: 612, height: 792)
        guard let context = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
        for page in 1...pageCount {
            context.beginPDFPage(nil)
            let line = CTLineCreateWithAttributedString(NSAttributedString(
                string: "\(page)", attributes: [.font: NSFont.boldSystemFont(ofSize: 220)]
            ))
            context.textPosition = CGPoint(x: 230, y: 320)
            CTLineDraw(line, context)
            context.endPDFPage()
        }
        context.closePDF()
    }
}
#endif
