import SwiftUI

/// Items in the menu-bar menu.
struct MenuBarContentView: View {
    let coordinator: AppCoordinator

    var body: some View {
        AppMenuItem(key: .menuGettingStarted) { coordinator.showWelcome() }
        if coordinator.supportsUpdateChecks {
            AppMenuItem(key: .menuCheckUpdates) { coordinator.showUpdates() }
        }
        AppMenuItem(key: .menuJobs, shortcut: "j") { coordinator.showJobs() }
        AppMenuItem(key: .menuSettings, shortcut: ",") { coordinator.showSettings() }
        AppMenuItem(key: .menuAbout) { coordinator.showAbout() }
        AppMenuItem(key: .menuPrivacy) { coordinator.openPrivacy() }
        AppMenuItem(key: .menuSupport) { coordinator.openSupport() }
        AppMenuDivider()
        AppMenuItem(key: .menuQuit, shortcut: "q") { coordinator.quit() }
    }
}
