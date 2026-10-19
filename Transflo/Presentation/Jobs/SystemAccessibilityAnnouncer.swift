import AppKit

/// Posts a high-priority VoiceOver announcement (ignored when VoiceOver is off).
struct SystemAccessibilityAnnouncer: AccessibilityAnnouncing {
    func announce(_ message: String) {
        NSAccessibility.post(element: NSApp as Any, notification: .announcementRequested, userInfo: [
            .announcement: message,
            .priority: NSAccessibilityPriorityLevel.high.rawValue
        ])
    }
}
