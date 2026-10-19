import Foundation
import os
import TransfloDomain
@preconcurrency import UserNotifications

/// Local notifications for finished jobs. Authorization is requested on first use, and
/// activating a notification reveals its files.
public final class UserNotificationPoster: NSObject, CompletionNotifying, UNUserNotificationCenterDelegate, Sendable {
    static let pathsKey = "transflo.revealPaths"
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.transflo.app",
        category: "Notifications"
    )

    private let revealer: any FileRevealing

    public init(revealer: any FileRevealing) {
        self.revealer = revealer
        super.init()
    }

    /// Becomes the notification center's delegate so taps are handled. Call once at launch.
    public func activate() {
        UNUserNotificationCenter.current().delegate = self
    }

    public func notify(title: String, body: String, revealing urls: [URL]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = [Self.pathsKey: urls.map(\.path)]
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { granted, error in
            if let error {
                Self.logger.error("Notification authorization failed: \(String(describing: error), privacy: .public)")
            }
            guard granted else { return }
            center.add(request)
        }
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner]
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        revealer.reveal(Self.urls(from: response.notification.request.content.userInfo))
    }

    static func urls(from userInfo: [AnyHashable: Any]) -> [URL] {
        (userInfo[pathsKey] as? [String] ?? []).map { URL(fileURLWithPath: $0) }
    }
}
