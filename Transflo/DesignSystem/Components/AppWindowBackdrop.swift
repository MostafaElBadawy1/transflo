import AppKit
import SwiftUI

/// Honors both Transflo's solid-surface preference and macOS Reduce Transparency.
struct AppWindowBackdrop: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        if InterfaceStyle.shared.preferences.solidSurfaces || reduceTransparency {
            AppColors.background
        } else {
            FrostedWindowBackdrop()
        }
    }
}

private struct FrostedWindowBackdrop: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .sidebar
        view.blendingMode = .behindWindow
        view.state = .followsWindowActiveState
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
