import Foundation

/// Supplies editor previews.
public protocol ToolPreviewProviding: Sendable {
    /// Size, length, page count and a thumbnail; missing facts are `nil`.
    func preview(of url: URL, format: FormatDescriptor?) async -> ToolPreview
    /// A PNG of the video frame at `seconds`.
    func frame(of url: URL, at seconds: Double) async -> Data?
    /// The thumbnail with `adjustments` applied, as PNG.
    func adjusted(_ thumbnail: Data, with adjustments: ImageAdjustments) async -> Data?
    /// Small PNGs of every PDF page in order; empty for anything else.
    func pageThumbnails(of url: URL) async -> [Data]
}
