import XCTest

/// README screenshots over a calm branded backdrop. Skipped in normal test runs; run through
/// `scripts/capture-screenshots.sh` (sets `TRANSFLO_SCREENSHOTS=1`).
@MainActor
final class MarketingScreenshotUITests: MarketingCaptureTestCase {
    /// Run with DEBUG + APP_STORE so marketing never advertises direct-edition-only actions.
    func testAppStoreFeatureScreens() throws {
        #if APP_STORE
        var app = launch([LaunchArgument.previewWheel, "actions"], appearance: "dark", backdrop: true)
        let wheel = app.dialogs[WindowIdentifier.wheel]
        XCTAssertTrue(wheel.waitForExistence(timeout: 10))
        XCTAssertFalse(wheel.buttons["Terminal"].exists, "Capture with APP_STORE enabled")
        XCTAssertTrue(wheel.buttons["Archive"].exists)
        capture(wheel, "appstore-actions-dark")
        app.terminate()
        for tool in ["trim", "normalize", "compress"] {
            app = launch([LaunchArgument.previewEditor, tool], appearance: "dark")
            capture(app.windows[WindowIdentifier.toolEditor], "editor-\(tool)-dark")
            app.terminate()
        }
        #else
        throw XCTSkip("App Store feature captures require DEBUG + APP_STORE compilation conditions")
        #endif
    }

    func testWheels() {
        for (wheel, language, appearance) in [
            ("convert", "en", "light"), ("convert", "en", "dark"),
            ("tools", "en", "light"), ("tools", "en", "dark"),
            ("actions", "en", "light"), ("actions", "en", "dark"), ("actions", "ar", "dark")
        ] {
            let app = launch([LaunchArgument.previewWheel, wheel, LaunchArgument.previewRecipes],
                             language: language, appearance: appearance,
                             backdrop: true)
            capture(app.dialogs[WindowIdentifier.wheel], "wheel-\(wheel)-\(language)-\(appearance)")
            if wheel == "tools" {
                let panel = app.dialogs[WindowIdentifier.wheel]
                panel.buttons["Recipes"].click()
                XCTAssertTrue(panel.buttons["Web photo"].waitForExistence(timeout: 5))
                capture(panel, "wheel-recipes-\(appearance)")
            }
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
            for (tab, name) in [("general", "customization"), ("general", "output"),
                                ("wheel", "wheel"), ("recipes", "recipes")] {
                let app = launch([LaunchArgument.openSettings, LaunchArgument.settingsTab, tab,
                                  LaunchArgument.previewRecipes], appearance: appearance)
                let settings = app.windows[WindowIdentifier.settings]
                XCTAssertTrue(settings.waitForExistence(timeout: 15))
                if name == "customization" { reveal(settings.staticTexts["Accent color"], in: settings) }
                if name == "output" {
                    XCTAssertTrue(settings.buttons["Balanced"].waitForExistence(timeout: 5))
                    settings.scrollViews.firstMatch.scroll(byDeltaX: 0, deltaY: -180)
                }
                if tab == "recipes" {
                    XCTAssertTrue(settings.buttons["settings.recipes.edit.Web photo"].waitForExistence(timeout: 5))
                }
                capture(settings, "settings-\(name)-\(appearance)")
                app.terminate()
            }
            let app = launch([LaunchArgument.openWelcome], appearance: appearance)
            capture(app.windows[WindowIdentifier.welcome], "welcome-\(appearance)")
            app.terminate()
        }
    }

    private func reveal(_ element: XCUIElement, in window: XCUIElement) {
        for _ in 0..<12 {
            if element.isHittable { return }
            window.scrollViews.firstMatch.scroll(byDeltaX: 0, deltaY: -180)
        }
        XCTAssertTrue(element.isHittable)
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
