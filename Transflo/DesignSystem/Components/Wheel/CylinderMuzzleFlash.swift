import SwiftUI

/// A cartoon muzzle flash over the firing position on a hit: a yellow starburst that blooms open.
/// With Reduce Motion it appears at full size without growing.
struct CylinderMuzzleFlash: View {
    let diameter: CGFloat

    @State private var bloomed = false

    var body: some View {
        CylinderStarburst()
            .fill(RadialGradient(colors: [.white, AppColors.muzzleFlash, AppColors.muzzleFlashEdge], center: .center,
                                 startRadius: 0, endRadius: diameter / 2))
            .overlay(CylinderStarburst().stroke(AppColors.muzzleFlashEdge, lineWidth: AppDimensions.Stroke.selection))
            .frame(width: diameter, height: diameter)
            .scaleEffect(bloomed ? 1 : 0.4)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onAppear {
                guard let animation = AppAnimations.muzzleFlash else {
                    bloomed = true
                    return
                }
                withAnimation(animation) { bloomed = true }
            }
    }
}

/// A star with alternating long and short points, like a comic-book "bang".
nonisolated struct CylinderStarburst: Shape {
    var points = 10
    /// The inner corners' distance from the center, as a share of the outer points'.
    var innerRatio: CGFloat = 0.55

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let corners = max(points, 3) * 2
        return Path { path in
            for corner in 0..<corners {
                // Every other outer point is a little shorter, for a hand-drawn look.
                let reach: CGFloat = corner.isMultiple(of: 2) ? (corner.isMultiple(of: 4) ? 1 : 0.82) : innerRatio
                let angle = CGFloat(corner) / CGFloat(corners) * 2 * .pi - .pi / 2
                let point = CGPoint(x: center.x + outer * reach * cos(angle), y: center.y + outer * reach * sin(angle))
                if corner == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            path.closeSubpath()
        }
    }
}

/// The fixed notch marking the firing position: a triangle pointing down into the top chamber.
nonisolated struct CylinderFiringNotch: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
