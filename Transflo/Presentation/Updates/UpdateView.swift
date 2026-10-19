import SwiftUI

struct UpdateView: View {
    let viewModel: UpdateViewModel
    let openRelease: () -> Void
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.large) {
            AppText(.menuCheckUpdates, style: .headline)
            HStack {
                if viewModel.isChecking { ProgressView().controlSize(.small) }
                AppText(viewModel.message, color: .secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            AppText(.updateInstalledVersion, arguments: [viewModel.currentVersion], color: .secondary)
            if let version = viewModel.availableVersion {
                AppText(.updateLatestVersion, arguments: [version])
                AppText(.updateInstallHint, color: .secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                AppButton(key: .updateClose, action: dismiss)
                Spacer()
                if viewModel.availableVersion != nil {
                    AppButton(key: .updateOpenRelease, variant: .primary, action: openRelease)
                } else {
                    AppButton(key: .updateRetry, variant: .primary, isEnabled: !viewModel.isChecking) {
                        Task { await viewModel.check() }
                    }
                }
            }
        }
        .padding(AppDimensions.Window.welcomePadding)
        .frame(width: AppDimensions.Window.welcomeWidth)
        .background(AppWindowBackdrop().ignoresSafeArea())
    }
}
