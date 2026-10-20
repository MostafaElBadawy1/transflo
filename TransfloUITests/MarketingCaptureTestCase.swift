import XCTest

/// Launch and capture helpers for the screenshot flows, which run only through
/// `scripts/capture-screenshots.sh` (it sets `TRANSFLO_SCREENSHOTS=1`).
@MainActor
class MarketingCaptureTestCase: TransfloUITestCase {
    override func setUpWithError() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["TRANSFLO_SCREENSHOTS"] == "1",
                          "README screenshots run only through scripts/capture-screenshots.sh")
        continueAfterFailure = false
    }

    /// `backdrop` puts the branded wallpaper behind floating panels; windows are shot without it.
    func launch(
        _ arguments: [String],
        language: String = "en",
        appearance: String = "light",
        backdrop: Bool = false,
        extraArguments: [String] = []
    ) -> XCUIApplication {
        let app = makeApplication()
        let captureArguments = [LaunchArgument.screenshotCapture]
            + (backdrop ? [LaunchArgument.screenshotBackdrop] : [])
        app.launchArguments = captureArguments + arguments + [
            "-settings.language", language, "-settings.appearance", appearance
        ] + extraArguments
        app.launch()
        app.activate()
        return app
    }

    /// Saves `element` as `<prefix>-<name>`. The capture script turns `readme-` shots into
    /// docs/screenshots/<name>.png and `marketing-` shots into build/marketing/captures/<name>.png.
    func capture(_ element: XCUIElement, _ name: String, prefix: String = "readme") {
        XCTAssertTrue(element.waitForExistence(timeout: 15), name)
        let app = XCUIApplication()
        for _ in 0..<3 {
            app.activate()
            // Let activation, glass, async thumbnails and the open animation settle.
            Thread.sleep(forTimeInterval: 1.2)
            guard app.state == .runningForeground else { continue }
            let screenshot = element.screenshot()
            guard app.state == .runningForeground else { continue }
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "\(prefix)-\(name)"
            attachment.lifetime = .keepAlways
            add(attachment)
            return
        }
        XCTFail("Transflo lost focus; refusing an obscured capture. Keep the Mac idle during screenshots.")
    }
}
