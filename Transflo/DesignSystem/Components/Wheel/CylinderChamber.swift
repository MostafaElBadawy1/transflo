import SwiftUI

/// One chamber of the revolver cylinder: a dark beveled bore with its option's label, or, in the
/// firing position, the brass cartridge with the label stamped on it.
struct CylinderChamber: View {
    let content: WheelWedgeContent
    let radius: CGFloat
    /// In the firing position.
    let isLoaded: Bool
    let labelSize: CGFloat

    @Environment(Localizer.self) private var localizer

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [AppColors.chamberBore, AppColors.cylinderSteelDark], center: .center,
                                     startRadius: radius * 0.55, endRadius: radius))
                .overlay(Circle().strokeBorder(AppRevolverCylinder.recessBevel,
                                               lineWidth: AppDimensions.Cylinder.chamberBevel))
            if isLoaded {
                cartridge.transition(.scale(scale: 0.6).combined(with: .opacity))
            }
            label
        }
        .frame(width: radius * 2, height: radius * 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        .accessibilityAddTraits(isLoaded ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(localizer.string(isLoaded ? .wheelFiringHint : .wheelChamberHint))
    }

    /// Brass case head with its rim and the silver primer above the stamped label.
    private var cartridge: some View {
        let diameter = radius * 2 * AppDimensions.Cylinder.cartridgeFill
        let primer = diameter * AppDimensions.Cylinder.primerFill
        return ZStack {
            Circle()
                .fill(RadialGradient(colors: [AppColors.brass, AppColors.brassDark], center: UnitPoint(x: 0.35, y: 0.3),
                                     startRadius: 0, endRadius: diameter * 0.7))
            Circle()
                .strokeBorder(AppColors.brassDark, lineWidth: AppDimensions.Stroke.hairline)
                .padding(diameter * 0.08)
            Circle()
                .fill(RadialGradient(colors: [AppColors.cylinderSteelLight, AppColors.cylinderSteel],
                                     center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: primer * 0.6))
                .overlay(Circle().strokeBorder(AppColors.brassDark, lineWidth: AppDimensions.Stroke.hairline))
                .frame(width: primer, height: primer)
                .offset(y: -diameter * 0.26)
        }
        .frame(width: diameter, height: diameter)
        .appShadow(AppShadows.petal)
    }

    private var label: some View {
        let color: AppTextColor = isLoaded ? .cartridge : .chamber
        return VStack(spacing: labelSize * 0.2) {
            if let symbol = content.symbol, !isLoaded {
                AppIcon(symbol: symbol, size: labelSize * 1.3)
                    .foregroundStyle(color.color)
            }
            AppWheelLabel(label: content.label, style: .wheelLabel(size: labelSize), color: color,
                          tracking: labelSize * 0.04)
        }
        .frame(width: radius * 1.6)
        .offset(y: isLoaded ? radius * 0.18 : 0)
    }

    private var spokenLabel: String {
        switch content.label {
        case .key(let key): localizer.string(key)
        case .verbatim(let text): text
        }
    }
}
