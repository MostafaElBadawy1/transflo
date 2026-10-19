/// Launch arguments understood by the app. Shared with the UI test target.
enum LaunchArgument {
    /// Opens the Settings window at launch, so UI tests do not depend on menu-bar automation.
    static let onboardingPage = "-TransfloOnboardingPage"
    static let openWelcome = "-TransfloOpenWelcome"
    static let openUpdates = "-TransfloOpenUpdates"
    static let openSettings = "-TransfloOpenSettings"
    /// Debug builds only: `-TransfloPreviewWheel <convert|tools|actions>` shows a static wheel.
    static let previewItemCount = "-TransfloPreviewItemCount"
    static let previewWheel = "-TransfloPreviewWheel"
    /// The defaults key the argument domain stores the preview wheel name under.
    static var previewWheelDefaultsKey: String { String(previewWheel.dropFirst()) }
    /// Debug builds only: `-TransfloPreviewJob <success|failure>` runs a scratch conversion to show the HUD.
    static let previewJob = "-TransfloPreviewJob"
    static var previewJobDefaultsKey: String { String(previewJob.dropFirst()) }
    /// Debug builds only: `-TransfloPreviewEditor <tool>` opens that tool's editor on a scratch image.
    static let previewEditor = "-TransfloPreviewEditor"
    static var previewEditorDefaultsKey: String { String(previewEditor.dropFirst()) }
    /// Debug builds only: `-TransfloScreenshotBackdrop` puts a calm branded wallpaper behind Transflo's
    /// windows and panels, so README screenshots never show the real desktop.
    /// Debug screenshot runs use a regular activation policy for reliable window focus.
    static let screenshotCapture = "-TransfloScreenshotCapture"
    static let screenshotBackdrop = "-TransfloScreenshotBackdrop"
    /// Debug builds only: `-TransfloPreviewJobs` runs scratch jobs and opens the Jobs window.
    static let previewJobs = "-TransfloPreviewJobs"
    /// Debug builds only: `-TransfloPreviewKeyboard` opens the keyboard-driven wheel on a scratch image.
    static let previewKeyboard = "-TransfloPreviewKeyboard"
    /// Debug builds only: `-TransfloPreviewShelf` puts scratch files on the floating shelf.
    static let previewShelf = "-TransfloPreviewShelf"
}
