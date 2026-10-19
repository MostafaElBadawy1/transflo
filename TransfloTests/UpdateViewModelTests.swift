import Testing
@testable import Transflo
import TransfloDomain

struct UpdateViewModelTests {
    @Test func presentsAvailableVersionAndClearsItAfterRetry() async {
        let checker = UpdateCheckerStub()
        let model = UpdateViewModel(checker: checker, currentVersion: "1.0.0")
        await model.check()
        #expect(model.message == .updateAvailable)
        #expect(model.availableVersion == "v2.0.0")
        #expect(!model.isChecking)
        await checker.setResult(.upToDate)
        await model.check()
        #expect(model.message == .updateCurrent)
        #expect(model.availableVersion == nil)
    }

    @Test func presentsMissingReleaseAndFailure() async {
        let checker = UpdateCheckerStub()
        let model = UpdateViewModel(checker: checker, currentVersion: "1.0.0")
        await checker.setResult(.noPublishedRelease)
        await model.check()
        #expect(model.message == .updateNoRelease)
        await checker.fail()
        await model.check()
        #expect(model.message == .updateFailed)
        #expect(!model.isChecking)
    }
}

private actor UpdateCheckerStub: AppUpdateChecking {
    private var result: AppUpdateStatus = .available(version: "v2.0.0")
    private var fails = false

    func setResult(_ result: AppUpdateStatus) { self.result = result }
    func fail() { fails = true }
    func check(currentVersion: String) async throws -> AppUpdateStatus {
        if fails { throw CheckError.unavailable }
        return result
    }

    private enum CheckError: Error { case unavailable }
}
