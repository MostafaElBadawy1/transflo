import Foundation
import Testing
@testable import TransfloSystem

@Suite("UserNotificationPoster")
struct UserNotificationPosterTests {
    @Test("revealed paths round-trip through the notification payload")
    func payload() {
        let info: [AnyHashable: Any] = [UserNotificationPoster.pathsKey: ["/tmp/a.png", "/tmp/b 2.png"]]
        #expect(UserNotificationPoster.urls(from: info).map(\.path) == ["/tmp/a.png", "/tmp/b 2.png"])
    }

    @Test("a payload without paths reveals nothing")
    func emptyPayload() {
        #expect(UserNotificationPoster.urls(from: [:]).isEmpty)
        #expect(UserNotificationPoster.urls(from: [UserNotificationPoster.pathsKey: 42]).isEmpty)
    }
}
