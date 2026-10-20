import SwiftUI

/// Semantic text colors available to `AppText`.
enum AppTextColor {
    case primary
    case secondary
    case accent
    case danger
    case onAccent
    /// Labels in a revolver chamber's dark bore, and stamped on the brass cartridge.
    case chamber
    case cartridge

    var color: Color {
        switch self {
        case .primary: AppColors.textPrimary
        case .secondary: AppColors.textSecondary
        case .accent: AppColors.accent
        case .danger: AppColors.danger
        case .onAccent: AppColors.accentContrast
        case .chamber: AppColors.chamberLabel
        case .cartridge: AppColors.cartridgeLabel
        }
    }
}
