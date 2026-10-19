import AppKit
import TransfloDomain

/// Native lifecycle hooks. Owns the composition root.
final class AppDelegate: NSObject, NSApplicationDelegate {
    let container = AppContainer()

    func applicationDidFinishLaunching(_ notification: Notification) {
        #if DEBUG
        let environment = ProcessInfo.processInfo.environment
        let isolatedUITest = environment["TRANSFLO_TEST_DEFAULTS_SUITE"]?.hasPrefix("TransfloUITests.") == true
        if isolatedUITest || ProcessInfo.processInfo.arguments.contains(LaunchArgument.screenshotCapture) {
            NSApp.setActivationPolicy(.regular)
        }
        #endif
        container.applyStartupPreferences()
        container.startDragWheel()
        container.startKeyboardPath()
        if ProcessInfo.processInfo.arguments.contains(LaunchArgument.openUpdates) {
            container.coordinator.showUpdates()
        } else if ProcessInfo.processInfo.arguments.contains(LaunchArgument.openSettings) {
            container.coordinator.showSettings()
        } else if onboardingRequested {
            container.coordinator.showWelcome(startingAt: onboardingStartPage)
        } else if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil,
                  container.coordinator.needsOnboarding,
                  !ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("-TransfloPreview") }) {
            container.coordinator.showWelcome()
        }
        #if DEBUG
        showPreviewWheelIfRequested()
        #endif
    }

    private var onboardingRequested: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        #if DEBUG
        return arguments.contains(LaunchArgument.openWelcome) || arguments.contains(LaunchArgument.onboardingPage)
        #else
        return arguments.contains(LaunchArgument.openWelcome)
        #endif
    }

    private var onboardingStartPage: Int {
        #if DEBUG
        max(1, UserDefaults.standard.integer(forKey: String(LaunchArgument.onboardingPage.dropFirst()))) - 1
        #else
        0
        #endif
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        container.coordinator.showWelcome()
        return true
    }

    #if DEBUG
    private var screenshotBackdrop: NSWindow?

    private func showPreviewWheelIfRequested() {
        if ProcessInfo.processInfo.arguments.contains(LaunchArgument.screenshotBackdrop) {
            screenshotBackdrop = ScreenshotBackdropWindow.make()
        }
        let names: [String: WheelKind] = ["convert": .convert, "tools": .tools, "actions": .actions]
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: LaunchArgument.previewWheelDefaultsKey), let kind = names[name] {
            container.previewWheel(kind)
        }
        if ProcessInfo.processInfo.arguments.contains(LaunchArgument.previewJobs) {
            container.previewJobs()
        }
        if ProcessInfo.processInfo.arguments.contains(LaunchArgument.previewKeyboard) {
            container.previewKeyboard()
        }
        if ProcessInfo.processInfo.arguments.contains(LaunchArgument.previewShelf) {
            container.previewShelf()
        }
        if let outcome = defaults.string(forKey: LaunchArgument.previewJobDefaultsKey) {
            container.previewJob(succeeding: outcome == "success")
        }
        if let name = defaults.string(forKey: LaunchArgument.previewEditorDefaultsKey),
           let tool = ToolKind(rawValue: name) {
            container.previewEditor(tool)
        }
    }
    #endif
}
