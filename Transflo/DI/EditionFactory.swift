import Foundation
import TransfloData
import TransfloDomain
import TransfloSystem

/// Factory for everything that differs between the direct edition (DMG, Homebrew) and the
/// sandboxed App Store edition. The `APP_STORE` build configuration selects the edition.
struct EditionFactory {
    let edition: AppEdition

    static let current: EditionFactory = {
        #if APP_STORE
        EditionFactory(edition: .appStore)
        #else
        EditionFactory(edition: .direct)
        #endif
    }()

    /// Shared across Move preparation and scheduling, so restored destinations are usable immediately.
    private static var folderAccess: SecurityScopedFolderAccess?

    func makeFolderAccess(localizer: Localizer, defaults: UserDefaults) -> SecurityScopedFolderAccess? {
        guard edition.needsFolderAccess else { return nil }
        if let access = Self.folderAccess { return access }
        let access = SecurityScopedFolderAccess(defaults: defaults) {
            .init(message: localizer.string(.folderAccessMessage), prompt: localizer.string(.folderAccessPrompt))
        }
        Self.folderAccess = access
        return access
    }

    var availableActions: [ActionKind] {
        ActionKind.allCases.filter { !edition.unavailableActions.contains($0) }
    }

    /// Settings › Wheel lists only what this edition can show.
    func makeWheelChoices(conversion: ConversionFactory, tools: ToolFactory) -> ListWheelChoicesUseCase {
        ListWheelChoicesUseCase(catalog: conversion.catalog, tools: tools.catalog, actions: availableActions)
    }

    /// The App Store edition asks for folder access before writing beside dropped files.
    func makeScheduler(
        base: any JobScheduling,
        hints: any HintPresenting,
        localizer: Localizer,
        defaults: UserDefaults
    ) -> any JobScheduling {
        guard let access = makeFolderAccess(localizer: localizer, defaults: defaults) else { return base }
        return FolderAccessJobScheduler(base: base, access: access, hints: hints)
    }

    /// `nil` on the App Store, which handles updates itself.
    func makeUpdateViewModel() -> UpdateViewModel? {
        guard edition.supportsUpdateChecks else { return nil }
        return UpdateViewModel(
            checker: GitHubUpdateChecker(),
            currentVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        )
    }

    /// Terminal apps offered in Settings; none where the Terminal action isn't available.
    func installedTerminals() -> [TerminalApp] {
        edition.unavailableActions.contains(.terminal) ? [] : WorkspaceTerminalOpener().installedApps()
    }

    func makeWheelFactory(
        bindings: WheelKeyBindings,
        localizer: Localizer,
        conversion: ConversionFactory,
        tools: ToolFactory,
        visibility: any WheelVisibilityRepository
    ) -> WheelFactory {
        // Decorator: the catalog decides what applies, Settings › Wheel what the user wants to see.
        WheelFactory(
            bindings: bindings,
            localizer: localizer,
            optionsProvider: VisibilityFilteredWheelOptionsProvider(
                base: CatalogWheelOptionsProvider(
                    catalog: conversion.catalog,
                    tools: tools.catalog,
                    fallback: PreviewWheelOptionsProvider(unavailableActions: edition.unavailableActions),
                    engines: tools.engines
                ),
                visibility: visibility
            )
        )
    }

    func makeCoordinator(
        settings: SettingsFactory,
        inputPreferences: any InputPreferencesRepository,
        applier: any InputPreferencesApplying,
        jobs: JobFactory,
        localizer: Localizer
    ) -> AppCoordinator {
        let coordinator = AppCoordinator(
            settingsFactory: settings,
            keySettingsFactory: KeySettingsFactory(
                repository: inputPreferences,
                applier: applier,
                installedTerminals: installedTerminals(),
                showsShortcut: edition.supportsFinderSelection
            ),
            jobCenter: jobs.center,
            updateViewModel: makeUpdateViewModel(),
            onboarding: settings.makeOnboardingViewModel(keys: inputPreferences),
            localizer: localizer
        )
        // Clicking the disc of a running or failed job opens the Jobs window.
        jobs.results.onShowJobs = { [weak coordinator] in coordinator?.showJobs() }
        return coordinator
    }
}
