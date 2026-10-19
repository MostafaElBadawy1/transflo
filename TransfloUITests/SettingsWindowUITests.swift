import XCTest

/// Smoke flows for the Settings window, opened through a launch argument
/// so the test does not depend on menu-bar automation.
@MainActor
final class SettingsWindowUITests: TransfloUITestCase {
    private func launch(language: String, appearance: String) -> XCUIApplication {
        continueAfterFailure = false
        let app = makeApplication()
        // `-settings.<key> <value>` overrides persisted values through the argument domain.
        app.launchArguments = [
            LaunchArgument.openSettings,
            "-settings.language", language,
            "-settings.appearance", appearance
        ]
        app.launch()
        app.activate()
        return app
    }

    /// Selects a tab and waits for its content. The window resizes to each page, so a click made
    /// while it is still settling can land on a neighboring tab; the tab is clicked again (at its
    /// current position) until its own content appears, up to three times.
    private func selectTab(_ title: String, in window: XCUIElement, app: XCUIApplication) {
        let tab = window.radioButtons[title]
        XCTAssertTrue(tab.waitForExistence(timeout: 5))
        let markers = ["General": "Language", "Customization": "Accent color", "Keys": "Tools wheel",
                       "Output": "Compression", "عام": "اللغة", "التخصيص": "لون التمييز",
                       "المفاتيح": "عجلة الأدوات", "الإخراج": "الضغط"]
        let marker = title == "Wheel" || title == "العجلة"
            ? window.staticTexts["settings.wheel.count"]
            : markers[title].map { window.staticTexts[$0] }
        for _ in 0..<3 {
            app.activate()
            tab.click()
            if marker?.waitForExistence(timeout: 3) ?? true { return }
        }
        XCTFail("The \(title) tab never showed its content")
    }

    private func toggle(_ label: String, in window: XCUIElement) -> XCUIElement {
        let checkbox = window.checkBoxes[label]
        return checkbox.exists ? checkbox : window.switches[label]
    }

    func testSettingsOpensWithEveryGeneralControlInEnglishLight() {
        let app = launch(language: "en", appearance: "light")
        let window = app.windows[WindowIdentifier.settings]
        XCTAssertTrue(window.waitForExistence(timeout: 10))
        XCTAssertTrue(window.staticTexts["Language"].exists)
        XCTAssertTrue(window.staticTexts["Open at login"].exists)
        selectTab("Keys", in: window, app: app)
        XCTAssertTrue(window.staticTexts["Tools wheel"].waitForExistence(timeout: 5))
        XCTAssertTrue(window.buttons["⌥⌘↩"].exists)
        XCTAssertGreaterThanOrEqual(window.radioGroups.count, 3)
        attachDiagnosticScreenshot(window, named: "settings-en-light")
    }

    func testCustomizationSurvivesQuitAndRelaunch() {
        continueAfterFailure = false
        let app = makeApplication()
        // No appearance override: this must read the value saved by the first process.
        app.launchArguments = [LaunchArgument.openSettings, "-settings.language", "en"]
        app.launch()
        app.activate()
        var window = app.windows[WindowIdentifier.settings]
        XCTAssertTrue(window.waitForExistence(timeout: 10))
        selectTab("Customization", in: window, app: app)
        window.buttons["Blue"].click()
        window.radioButtons["Dark"].click()
        window.radioButtons["Large"].click()
        window.scrollViews.firstMatch.scroll(byDeltaX: 0, deltaY: -450)
        let glass = toggle("Liquid Glass", in: window)
        let motion = toggle("Reduce motion", in: window)
        glass.click()
        motion.click()
        let savedGlass = (glass.value as? NSNumber)?.intValue
        let savedMotion = (motion.value as? NSNumber)?.intValue
        XCTAssertNotNil(savedGlass)
        XCTAssertNotNil(savedMotion)
        app.terminate()
        app.launch()
        app.activate()
        window = app.windows[WindowIdentifier.settings]
        XCTAssertTrue(window.waitForExistence(timeout: 10))
        selectTab("Customization", in: window, app: app)
        XCTAssertTrue(window.buttons["Blue"].isSelected)
        XCTAssertEqual((window.radioButtons["Dark"].value as? NSNumber)?.intValue, 1)
        XCTAssertEqual((window.radioButtons["Large"].value as? NSNumber)?.intValue, 1)
        window.scrollViews.firstMatch.scroll(byDeltaX: 0, deltaY: -450)
        XCTAssertEqual((toggle("Liquid Glass", in: window).value as? NSNumber)?.intValue, savedGlass)
        XCTAssertEqual((toggle("Reduce motion", in: window).value as? NSNumber)?.intValue, savedMotion)
        attachDiagnosticScreenshot(window, named: "settings-persisted-after-relaunch")
    }

    func testOutputNamingAndAdaptiveHeight() {
        let app = launch(language: "en", appearance: "light")
        let window = app.windows[WindowIdentifier.settings]
        XCTAssertTrue(window.waitForExistence(timeout: 10))
        selectTab("Customization", in: window, app: app)
        XCTAssertTrue(window.staticTexts["Accent color"].waitForExistence(timeout: 5))
        let tallHeight = window.frame.height
        selectTab("Output", in: window, app: app)
        XCTAssertTrue(window.staticTexts["Example: photo (cropped).jpg"].waitForExistence(timeout: 5))
        let compact = expectation(for: NSPredicate { _, _ in window.frame.height < tallHeight - 50 },
                                  evaluatedWith: nil)
        wait(for: [compact], timeout: 5)
        XCTAssertFalse(window.radioButtons["Tools"].exists)
        window.radioButtons["Word"].click()
        XCTAssertTrue(window.staticTexts["Example: photo Cropped.jpg"].waitForExistence(timeout: 5))
        window.radioButtons["Parentheses"].click()
        XCTAssertTrue(window.staticTexts["Example: photo (cropped).jpg"].waitForExistence(timeout: 5))
        let outputHeight = window.frame.height
        XCTAssertLessThan(outputHeight, 520)
        window.buttons["Size limit"].click()
        XCTAssertTrue(window.textFields["transflo.compression.target"].waitForExistence(timeout: 5))
        let expanded = expectation(for: NSPredicate { _, _ in window.frame.height > outputHeight + 25 },
                                   evaluatedWith: nil)
        wait(for: [expanded], timeout: 5)
        XCTAssertTrue(window.textFields["transflo.compression.target"].isHittable)
        window.buttons["Balanced"].click()
        let restored = expectation(for: NSPredicate { _, _ in abs(window.frame.height - outputHeight) < 3 },
                                   evaluatedWith: nil)
        wait(for: [restored], timeout: 5)
        attachDiagnosticScreenshot(window, named: "settings-output-content-height")
    }

    func testEachTabFitsItsContentInEnglishAndArabic() {
        for (language, tabs) in [("en", ["General", "Customization", "Wheel", "Keys", "Output"]),
                                  ("ar", ["عام", "التخصيص", "العجلة", "المفاتيح", "الإخراج"])] {
            let app = launch(language: language, appearance: language == "ar" ? "dark" : "light")
            let window = app.windows[WindowIdentifier.settings]
            XCTAssertTrue(window.waitForExistence(timeout: 10))
            let width = window.frame.width
            for tab in tabs {
                selectTab(tab, in: window, app: app)
                XCTAssertEqual(window.frame.width, width, accuracy: 1)
                XCTAssertLessThan(window.frame.height, 680)
                attachDiagnosticScreenshot(window, named: "settings-\(language)-\(tab)")
            }
            app.terminate()
        }
    }
    func testSwitchingPagesAndLanguageDoesNotLeaveInactiveSegments() {
        let app = launch(language: "en", appearance: "light")
        let window = app.windows[WindowIdentifier.settings]
        XCTAssertTrue(window.waitForExistence(timeout: 10))
        let width = window.frame.width
        selectTab("Customization", in: window, app: app)
        XCTAssertFalse(window.radioButtons["English"].exists)
        XCTAssertFalse(window.radioButtons["العربية"].exists)
        window.buttons["Blue"].click()
        XCTAssertTrue(window.buttons["Blue"].isSelected)
        XCTAssertTrue(window.staticTexts["Liquid Glass"].exists)
        XCTAssertTrue(window.staticTexts["Reduce motion"].exists)
        let labelLeft = window.staticTexts["Wheel size"].frame.minX
        let appearanceX = window.radioButtons["Light"].frame.minX - window.frame.minX
        for size in ["Large", "Compact", "Standard"] {
            window.radioButtons[size].click()
            XCTAssertEqual((window.radioButtons[size].value as? NSNumber)?.intValue, 1)
            XCTAssertEqual(window.staticTexts["Wheel size"].frame.minX, labelLeft, accuracy: 1)
            XCTAssertEqual(window.frame.width, width, accuracy: 1)
            let settled = expectation(for: NSPredicate { _, _ in
                abs(window.radioButtons["Light"].frame.minX - window.frame.minX - appearanceX) < 1
            }, evaluatedWith: nil)
            wait(for: [settled], timeout: 3)
        }
        selectTab("General", in: window, app: app)
        window.radioButtons["العربية"].click()
        selectTab("التخصيص", in: window, app: app)
        XCTAssertTrue(window.staticTexts["المظهر"].exists)
        XCTAssertTrue(window.staticTexts["لون التمييز"].exists)
        XCTAssertFalse(window.radioButtons["English"].exists)
        XCTAssertFalse(window.radioButtons["العربية"].exists)
        selectTab("عام", in: window, app: app)
        window.radioButtons["English"].click()
        selectTab("Customization", in: window, app: app)
        attachDiagnosticScreenshot(window, named: "settings-no-inactive-controls")
    }
}
