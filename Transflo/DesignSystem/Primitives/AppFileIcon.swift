import AppKit
import SwiftUI

/// A file's Finder icon.
struct AppFileIcon: View {
    let url: URL

    var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
            .resizable()
            .interpolation(.high)
            .frame(width: AppDimensions.Shelf.iconSize, height: AppDimensions.Shelf.iconSize)
            .accessibilityHidden(true)
    }
}
