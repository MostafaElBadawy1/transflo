import AppKit
import SwiftUI

/// Shows PNG/JPEG data scaled to fit, or a quiet placeholder while it loads. `backdrop` shows
/// through transparent pixels (the surface color by default).
struct AppPreviewImage: View {
    let data: Data?
    var backdrop = AppColors.surface

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppDimensions.Radius.medium).fill(backdrop)
            if let data, let image = NSImage(data: data) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView().controlSize(.small)
            }
        }
    }
}
