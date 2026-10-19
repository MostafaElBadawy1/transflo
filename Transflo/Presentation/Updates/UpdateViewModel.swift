import Observation
import TransfloDomain

@Observable
final class UpdateViewModel {
    private(set) var message: L10nKey = .updateChecking
    private(set) var availableVersion: String?
    private(set) var isChecking = false
    let currentVersion: String
    private let checker: any AppUpdateChecking

    init(checker: any AppUpdateChecking, currentVersion: String) {
        self.checker = checker
        self.currentVersion = currentVersion
    }

    func check() async {
        guard !isChecking else { return }
        isChecking = true
        availableVersion = nil
        message = .updateChecking
        defer { isChecking = false }
        do {
            switch try await checker.check(currentVersion: currentVersion) {
            case .available(let version):
                availableVersion = version
                message = .updateAvailable
            case .upToDate: message = .updateCurrent
            case .noPublishedRelease: message = .updateNoRelease
            }
        } catch {
            message = .updateFailed
        }
    }
}
