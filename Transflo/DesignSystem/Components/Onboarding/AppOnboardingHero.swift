import SwiftUI

/// Transflo's full-width welcome canvas, tinted with the chosen accent in light and dark.
/// The canvas settles in, the icon pops, and the copy follows line by line.
struct AppOnboardingHero: View {
    @State private var shown = false

    var body: some View {
        VStack(spacing: AppDimensions.Spacing.large) {
            AppAppIcon(size: AppDimensions.Onboarding.heroIconSize)
            AppText(.onboardingWelcome, style: .welcomeTitle).appEntrance(step: 2)
            AppText(.welcomeTitle, style: .headline).appEntrance(step: 3)
            AppText(.welcomeDescription, color: .secondary)
                .fixedSize(horizontal: false, vertical: true)
                .appEntrance(step: 4)
            AppText(.onboardingWelcomeHint, style: .caption, color: .secondary).appEntrance(step: 5)
        }
        .multilineTextAlignment(.center)
        .padding(AppDimensions.Onboarding.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: [AppColors.onboardingStart, AppColors.onboardingEnd],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: AppDimensions.Radius.large))
        // A chosen accent is a translucent tint, so the canvas needs an opaque base beneath it.
        .background(AppColors.background, in: RoundedRectangle(cornerRadius: AppDimensions.Radius.large))
        .scaleEffect(shown ? 1 : AppDimensions.Onboarding.entranceScale)
        .opacity(shown ? 1 : 0)
        .onAppear {
            guard let animation = AppAnimations.entrance else {
                shown = true
                return
            }
            withAnimation(animation) { shown = true }
        }
    }
}
