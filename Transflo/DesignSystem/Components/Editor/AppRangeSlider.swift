import SwiftUI

/// A track with two handles selecting `lower...upper` inside `bounds` (left to right in every
/// language, like a timeline).
struct AppRangeSlider: View {
    @Binding var lower: Double
    @Binding var upper: Double
    let bounds: ClosedRange<Double>
    /// Smallest allowed distance between the handles.
    let minimumSpan: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width - AppDimensions.Editor.handleSize
            ZStack(alignment: .leading) {
                Capsule().fill(AppColors.divider).frame(height: AppDimensions.Editor.trackHeight)
                Capsule().fill(AppColors.accent)
                    .frame(width: max(0, position(upper, width) - position(lower, width)),
                           height: AppDimensions.Editor.trackHeight)
                    .offset(x: position(lower, width) + AppDimensions.Editor.handleSize / 2)
                handle(at: position(lower, width), width: width) { lower = min($0, upper - minimumSpan) }
                handle(at: position(upper, width), width: width) { upper = max($0, lower + minimumSpan) }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: AppDimensions.Editor.handleSize * 2)
        .environment(\.layoutDirection, .leftToRight)
    }

    private var span: Double { max(bounds.upperBound - bounds.lowerBound, .ulpOfOne) }

    private func position(_ value: Double, _ width: CGFloat) -> CGFloat {
        CGFloat((value - bounds.lowerBound) / span) * width
    }

    private func handle(at x: CGFloat, width: CGFloat, update: @escaping (Double) -> Void) -> some View {
        Circle()
            .fill(AppColors.surface)
            .overlay(Circle().strokeBorder(AppColors.accent, lineWidth: AppDimensions.Stroke.selection))
            .frame(width: AppDimensions.Editor.handleSize, height: AppDimensions.Editor.handleSize)
            .offset(x: x)
            .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
                let center = drag.location.x + x - AppDimensions.Editor.handleSize / 2
                let fraction = Double(min(max(center, 0), width) / width)
                update(min(max(bounds.lowerBound + fraction * span, bounds.lowerBound), bounds.upperBound))
            })
    }
}
