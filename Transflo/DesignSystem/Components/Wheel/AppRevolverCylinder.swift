import SwiftUI
import TransfloDomain

/// Russian Roulette mode's wheel: a revolver cylinder seen from the front. Brushed steel with one
/// beveled chamber per option around the hub, and a fixed firing position at 12 o'clock whose
/// chamber holds the brass cartridge.
///
/// Layout comes from `CylinderAim`, which also hit-tests, so the drawn firing hole and the drop
/// target always agree. The steel and chambers turn as one; each chamber turns back by the same
/// angle so its label stays upright. Light falls from a fixed direction, so it doesn't turn.
struct AppRevolverCylinder: View {
    let wedges: [WheelWedgeContent]
    let cylinder: CylinderAim
    let hubTitle: L10nKey
    let hubGlyph: String
    var hubDetail: String?
    var itemCount = 1
    var shot: RouletteOutcome?

    @State private var recoil = 0

    var body: some View {
        ZStack {
            turningCylinder
                .rotationEffect(.degrees(cylinder.rotationDegrees))
            lighting
            firingNotch
            AppWheelHub(
                wellDiameter: (cylinder.geometry.innerRadius - AppDimensions.Wheel.petalGap) * 2,
                title: .key(hubTitle),
                glyph: hubGlyph,
                detail: hubDetail
            )
            .overlay(alignment: cylinder.geometry.isRightToLeft ? .topLeading : .topTrailing) {
                if itemCount > 1 { AppCountBadge(count: itemCount) }
            }
            if shot == .hit {
                CylinderMuzzleFlash(diameter: holeRadius * 2 * AppDimensions.Cylinder.flashScale)
                    .offset(y: -chamberRadius)
            }
        }
        .frame(width: outerRadius * 2, height: outerRadius * 2)
        .keyframeAnimator(initialValue: CylinderRecoil(), trigger: recoil) { content, motion in
            content.offset(y: motion.offset).rotationEffect(.degrees(motion.angle))
        } keyframes: { _ in
            KeyframeTrack(\.offset) { recoilKeyframes }
            KeyframeTrack(\.angle) { kickKeyframes }
        }
        .padding(AppDimensions.Wheel.margin)
        // Geometry already mirrors for RTL; stop SwiftUI from mirroring offsets a second time.
        .environment(\.layoutDirection, .leftToRight)
        .animation(AppAnimations.cylinderTurn, value: cylinder.turns)
        .onChange(of: shot) { _, shot in
            if shot == .hit, AppAnimations.cylinderRecoil { recoil += 1 }
        }
    }

    /// Fixed at 12 o'clock, just inside the rim.
    private var firingNotch: some View {
        let height = AppDimensions.Cylinder.firingNotchHeight
        return CylinderFiringNotch()
            .fill(AppColors.brass)
            .overlay(CylinderFiringNotch().stroke(AppColors.brassDark, lineWidth: AppDimensions.Stroke.hairline))
            .frame(width: AppDimensions.Cylinder.firingNotchWidth, height: height)
            .offset(y: -outerRadius + AppDimensions.Cylinder.rimBevel + height / 2)
            .accessibilityHidden(true)
    }

    private var outerRadius: CGFloat { cylinder.geometry.outerRadius }
    private var chamberRadius: CGFloat { cylinder.chamberRadius }
    private var holeRadius: CGFloat { cylinder.holeRadius }

    private var labelSize: CGFloat {
        let range = WheelLabelMetrics.fontRange
        let preferred = cylinder.holeRadius * Double(AppDimensions.Cylinder.labelPerRadius)
        return CGFloat(min(max(preferred, range.lowerBound), range.upperBound))
    }

    /// The steel, the center bore and the chambers: everything that turns.
    private var turningCylinder: some View {
        ZStack {
            Circle()
                .fill(AngularGradient(colors: Self.brushedSteel, center: .center))
                .background(Circle().fill(AppColors.cylinderSteelDark).appShadow(AppShadows.floating))
            ForEach(1...AppDimensions.Cylinder.machiningRings, id: \.self) { ring in
                Circle()
                    .stroke(AppColors.cylinderSteelLight.opacity(0.14), lineWidth: AppDimensions.Stroke.hairline / 2)
                    .padding(outerRadius * CGFloat(ring) / CGFloat(AppDimensions.Cylinder.machiningRings + 1))
            }
            Circle()
                .fill(AppColors.chamberBore)
                .overlay(Circle().strokeBorder(Self.recessBevel, lineWidth: AppDimensions.Cylinder.chamberBevel))
                .frame(width: cylinder.geometry.innerRadius * 2, height: cylinder.geometry.innerRadius * 2)
            ForEach(Array(wedges.enumerated()), id: \.element.id) { index, wedge in
                CylinderChamber(
                    content: wedge,
                    radius: holeRadius,
                    isLoaded: index == cylinder.selectedIndex,
                    labelSize: labelSize
                )
                .rotationEffect(.degrees(-cylinder.rotationDegrees))
                .offset(chamberOffset(index))
            }
        }
        .frame(width: outerRadius * 2, height: outerRadius * 2)
    }

    /// The beveled rim and a soft sheen from the top left.
    private var lighting: some View {
        ZStack {
            Circle().strokeBorder(Self.raisedBevel, lineWidth: AppDimensions.Cylinder.rimBevel)
            Circle().fill(RadialGradient(colors: [AppColors.cylinderSteelLight.opacity(0.22), .clear],
                                         center: UnitPoint(x: 0.3, y: 0.22), startRadius: 0,
                                         endRadius: outerRadius * 1.2))
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func chamberOffset(_ index: Int) -> CGSize {
        let radians = cylinder.geometry.centerAngle(ofWedge: index) * .pi / 180
        return CGSize(width: chamberRadius * sin(radians), height: -chamberRadius * cos(radians))
    }

    @KeyframeTrackContentBuilder<CGFloat> private var recoilKeyframes: some KeyframeTrackContent<CGFloat> {
        let distance = AppDimensions.Cylinder.recoilDistance
        CubicKeyframe(-distance, duration: 0.05)
        CubicKeyframe(distance * 0.5, duration: 0.07)
        CubicKeyframe(-distance * 0.25, duration: 0.07)
        CubicKeyframe(0, duration: 0.08)
    }

    @KeyframeTrackContentBuilder<Double> private var kickKeyframes: some KeyframeTrackContent<Double> {
        CubicKeyframe(-4, duration: 0.05)
        CubicKeyframe(2, duration: 0.07)
        CubicKeyframe(0, duration: 0.1)
    }

    /// Alternating lit and shaded steel around the disc reads as a brushed, turned finish.
    private static let brushedSteel: [Color] = [
        AppColors.cylinderSteel, AppColors.cylinderSteelLight, AppColors.cylinderSteel, AppColors.cylinderSteelDark,
        AppColors.cylinderSteel, AppColors.cylinderSteelLight, AppColors.cylinderSteel, AppColors.cylinderSteelDark,
        AppColors.cylinderSteel
    ]
    /// Lit at the top left: a raised edge. Reversed, an edge cut into the steel.
    static let raisedBevel = LinearGradient(colors: [AppColors.cylinderSteelLight, AppColors.cylinderSteelDark],
                                            startPoint: .topLeading, endPoint: .bottomTrailing)
    static let recessBevel = LinearGradient(colors: [AppColors.cylinderSteelDark, AppColors.cylinderSteelLight],
                                            startPoint: .topLeading, endPoint: .bottomTrailing)
}

/// The cylinder's kick on a hit: a jolt up and a small twist, settling back.
private struct CylinderRecoil {
    var offset: CGFloat = 0
    var angle: Double = 0
}
