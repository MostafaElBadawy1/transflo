import XCTest

/// README screenshots over a calm branded backdrop. Skipped in normal test runs; run through
/// `scripts/capture-screenshots.sh` (sets `TRANSFLO_SCREENSHOTS=1`).
@MainActor
final class MarketingScreenshotUITests: TransfloUITestCase {
    override func setUpWithError() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["TRANSFLO_SCREENSHOTS"] == "1",
                          "README screenshots run only through scripts/capture-screenshots.sh")
        continueAfterFailure = false
    }

    /// `backdrop` puts the branded wallpaper behind floating panels; windows are shot without it.
    private func launch(
        _ arguments: [String],
        language: String = "en",
        appearance: String = "light",
        backdrop: Bool = false
    ) -> XCUIApplication {
        let app = makeApplication()
        let captureArguments = [LaunchArgument.screenshotCapture]
            + (backdrop ? [LaunchArgument.screenshotBackdrop] : [])
        app.launchArguments = captureArguments + arguments + [
            "-settings.language", language, "-settings.appearance", appearance
        ]
        app.launch()
        app.activate()
        return app
    }

    /// Saves `element` as `readme-<name>`; the capture script turns it into docs/screenshots/<name>.png.
    private func capture(_ element: XCUIElement, _ name: String) {
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
            attachment.name = "readme-\(name)"
            attachment.lifetime = .keepAlways
            add(attachment)
            return
        }
        XCTFail("Transflo lost focus; refusing an obscured capture. Keep the Mac idle during screenshots.")
    }

    func testWheels() {
        for (wheel, language, appearance) in [
            ("convert", "en", "light"), ("convert", "en", "dark"),
            ("tools", "en", "light"), ("tools", "en", "dark"),
            ("actions", "en", "light"), ("actions", "en", "dark"), ("actions", "ar", "dark")
        ] {
            let app = launch([LaunchArgument.previewWheel, wheel], language: language, appearance: appearance,
                             backdrop: true)
            capture(app.dialogs[WindowIdentifier.wheel], "wheel-\(wheel)-\(language)-\(appearance)")
            app.terminate()
        }
    }

    func testEditors() {
        for (tool, appearance) in [("annotate", "light"), ("crop", "light"), ("crop", "dark"),
                                   ("addBackground", "light"), ("addBackground", "dark"),
                                   ("reorganizePages", "light"), ("rename", "dark"), ("collage", "light")] {
            let app = launch([LaunchArgument.previewEditor, tool], appearance: appearance)
            capture(app.windows[WindowIdentifier.toolEditor], "editor-\(tool)-\(appearance)")
            app.terminate()
        }
    }

    func testShelfAndJobs() {
        var app = launch([LaunchArgument.previewShelf], backdrop: true)
        capture(app.dialogs[WindowIdentifier.shelf], "shelf")
        app.terminate()
        app = launch([LaunchArgument.previewJobs], appearance: "dark")
        let jobs = app.windows[WindowIdentifier.jobs]
        XCTAssertTrue(jobs.buttons["Show in Finder"].waitForExistence(timeout: 15))
        capture(jobs, "jobs")
        app.terminate()
    }

    func testSettingsAndWelcome() {
        for appearance in ["light", "dark"] {
            var app = launch([LaunchArgument.openSettings], appearance: appearance)
            let settings = app.windows[WindowIdentifier.settings]
            XCTAssertTrue(settings.waitForExistence(timeout: 15))
            settings.radioButtons["Customization"].click()
            XCTAssertTrue(settings.staticTexts["Accent color"].waitForExistence(timeout: 5))
            capture(settings, "settings-customization-\(appearance)")
            settings.radioButtons["Wheel"].click()
            XCTAssertTrue(settings.descendants(matching: .any)["settings.wheel.count"].waitForExistence(timeout: 5))
            capture(settings, "settings-wheel-\(appearance)")
            settings.radioButtons["Keys"].click()
            XCTAssertTrue(settings.staticTexts["Tools wheel"].waitForExistence(timeout: 5))
            if appearance == "light" { capture(settings, "settings-keys") }
            settings.radioButtons["Output"].click()
            XCTAssertTrue(settings.buttons["Balanced"].waitForExistence(timeout: 5))
            // Show the target-size control the README and the video describe.
            settings.buttons["Size limit"].click()
            capture(settings, "settings-output-\(appearance)")
            app.terminate()
            app = launch([LaunchArgument.openWelcome], appearance: appearance)
            capture(app.windows[WindowIdentifier.welcome], "welcome-\(appearance)")
            app.terminate()
        }
    }

    func testOnboardingPages() {
        for (language, appearance) in [("en", "light"), ("ar", "dark")] {
            let app = launch([LaunchArgument.openWelcome], language: language, appearance: appearance)
            let window = app.windows[WindowIdentifier.welcome]
            for page in 1...5 {
                capture(window, "onboarding-\(page)-\(language)-\(appearance)")
                if page < 5 { window.buttons[language == "ar" ? "متابعة" : "Continue"].click() }
            }
            app.terminate()
        }
    }
}
