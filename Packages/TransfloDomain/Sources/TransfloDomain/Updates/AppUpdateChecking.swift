/// Strategy for asking where the latest public stable release stands relative to this build.
public protocol AppUpdateChecking: Sendable {
    func check(currentVersion: String) async throws -> AppUpdateStatus
}
