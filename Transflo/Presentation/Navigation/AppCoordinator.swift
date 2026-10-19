import AppKit
import Observation
import SwiftUI
import TransfloData

/// Owns app-level navigation: the Welcome, Settings, Updates and Jobs windows, the About panel and quitting.
///
/// Transflo is an agent app (no Dock icon), so windows are activated explicitly to come to the front.
final class AppCoordinator {
    private let settingsFactory: SettingsFactory
    private let keySettingsFactory: KeySettingsFactory
    private let jobCenter: JobCenter
    private let localizer: Localizer
    private var welcomeWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var jobsWindow: NSWindow?
    private var updateWindow: NSWindow?
    private let onboarding: OnboardingViewModel
    /// `nil` in the App Store edition, where the store handles updates.
    private let updateViewModel: UpdateViewModel?

    init(
        settingsFactory: SettingsFactory,
        keySettingsFactory: KeySettingsFactory,
        jobCenter: JobCenter,
        updateViewModel: UpdateViewModel?,
        onboarding: OnboardingViewModel,
        localizer: Localizer
    ) {
        self.onboarding = onboarding
        self.settingsFactory = settingsFactory
        self.keySettingsFactory = keySettingsFactory
        self.jobCenter = jobCenter
        self.updateViewModel = updateViewModel
        self.localizer = localizer
    }

    /// Whether the menu offers Check for Updates (not in the App Store edition).
    var supportsUpdateChecks: Bool { updateViewModel != nil }

    func showUpdates() {
        guard let updateViewModel else { return }
        if updateWindow == nil {
            let viewModel = updateViewModel
            let root = AppLocalizedRoot(localizer: localizer) { [weak self] in
                UpdateView(viewModel: viewModel, openRelease: {
                    if let url = GitHubUpdateChecker.releasesURL { NSWorkspace.shared.open(url) }
                }, dismiss: { self?.updateWindow?.close() })
            }
            let window = AppWindow.make(contentViewController: NSHostingController(rootView: root),
                                        identifier: WindowIdentifier.updates)
            updateWindow = window
            trackTitle(of: window, key: .menuCheckUpdates)
        }
        NSApp.activate()
        updateWindow?.makeKeyAndOrderFront(nil)
        Task { await updateViewModel.check() }
    }

    /// Shows the Jobs window, creating it on first use.
    func showJobs() {
        let window = jobsWindow ?? makeJobsWindow()
        jobsWindow = window
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    private func makeJobsWindow() -> NSWindow {
        let viewModel = JobListViewModel(jobCenter: jobCenter)
        let root = AppLocalizedRoot(localizer: localizer) { JobsView(viewModel: viewModel) }
        let window = AppWindow.make(
            contentViewController: NSHostingController(rootView: root), identifier: WindowIdentifier.jobs
        )
        trackTitle(of: window, key: .jobsTitle)
        return window
    }

    var needsOnboarding: Bool { onboarding.needsOnboarding }

    func showWelcome(startingAt page: Int = 0) {
        onboarding.start(at: page)
        if welcomeWindow == nil {
            let model = onboarding
            let root = AppLocalizedRoot(localizer: localizer) { [weak self] in
                WelcomeView(model: model, openSettings: {
                    self?.welcomeWindow?.close()
                    self?.showSettings()
                }, dismiss: { self?.welcomeWindow?.close() })
            }
            let window = AppWindow.make(contentViewController: NSHostingController(rootView: root),
                                        identifier: WindowIdentifier.welcome)
            welcomeWindow = window
            trackTitle(of: window, key: .welcomeWindowTitle)
        }
        welcomeWindow?.animationBehavior = AppAnimations.windowPresentation
        NSApp.activate()
        welcomeWindow?.makeKeyAndOrderFront(nil)
        // A menu-bar app may not be granted activation (another app is busy in front);
        // the tour must still be visible rather than opening behind other windows.
        welcomeWindow?.orderFrontRegardless()
    }

    /// Shows the Settings window, creating it on first use.
    func showSettings() {
        let window = settingsWindow ?? makeSettingsWindow()
        settingsWindow = window
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    /// Shows the standard About panel.
    func showAbout() {
        NSApp.activate()
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    func openPrivacy() {
        if let url = URL(string: "https://transflo.ali-fayed.com/privacy") { NSWorkspace.shared.open(url) }
    }

    func openSupport() {
        if let url = URL(string: "https://transflo.ali-fayed.com/support") { NSWorkspace.shared.open(url) }
    }

    /// Drain cancellation before exiting, so helpers and staging are cleaned up.
    func quit() {
        jobCenter.cancelAll()
        Task { [jobCenter] in
            await jobCenter.waitUntilIdle()
            NSApp.terminate(nil)
        }
    }

    private func makeSettingsWindow() -> NSWindow {
        let viewModel = settingsFactory.makeViewModel()
        let keys = keySettingsFactory.makeViewModel()
        let customization = settingsFactory.makeCustomizationViewModel()
        let tools = settingsFactory.makeToolPreferencesViewModel()
        let wheel = settingsFactory.makeWheelVisibilityViewModel()
        let root = AppLocalizedRoot(localizer: localizer) {
            SettingsView(viewModel: viewModel, keys: keys, customization: customization, tools: tools, wheel: wheel)
        }
        let host = NSHostingController(rootView: root)
        host.sizingOptions = [.intrinsicContentSize, .preferredContentSize]
        let window = AppWindow.make(contentViewController: host, identifier: WindowIdentifier.settings)
        trackTitle(of: window, key: .settingsTitle)
        return window
    }

    /// Keeps a window title in the current language, re-applying it whenever the language changes.
    private func trackTitle(of window: NSWindow, key: L10nKey) {
        withObservationTracking {
            window.title = localizer.string(key)
        } onChange: { [weak self, weak window] in
            Task { @MainActor in
                guard let self, let window else { return }
                self.trackTitle(of: window, key: key)
            }
        }
    }
}
