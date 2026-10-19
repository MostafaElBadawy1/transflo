import TransfloDomain

/// Builds the Settings feature's ViewModel with fully constructed dependencies.
struct SettingsFactory {
    let repository: any SettingsRepository
    let preferredLanguages: any PreferredLanguagesProviding
    let launchAtLogin: any LaunchAtLoginService
    let versionProvider: any AppVersionProviding
    let languageApplier: any LanguageApplying
    let appearanceApplier: any AppearanceApplying
    let wheelChoices: ListWheelChoicesUseCase
    let wheelVisibility: any WheelVisibilityRepository

    func makeOnboardingViewModel(keys: any InputPreferencesRepository) -> OnboardingViewModel {
        OnboardingViewModel(repository: repository, keys: keys,
                            getLogin: GetLaunchAtLoginStatusUseCase(service: launchAtLogin),
                            setLogin: SetLaunchAtLoginUseCase(service: launchAtLogin))
    }

    func makeToolPreferencesViewModel() -> ToolPreferencesViewModel {
        ToolPreferencesViewModel(repository: repository)
    }

    func makeWheelVisibilityViewModel() -> WheelVisibilityViewModel {
        WheelVisibilityViewModel(choices: wheelChoices, repository: wheelVisibility)
    }

    func makeCustomizationViewModel() -> CustomizationViewModel {
        CustomizationViewModel(repository: repository)
    }

    func makeViewModel() -> SettingsViewModel {
        SettingsViewModel(
            loadSettings: LoadSettingsUseCase(repository: repository, preferredLanguages: preferredLanguages),
            updateLanguage: UpdateLanguageUseCase(repository: repository),
            updateAppearance: UpdateAppearanceUseCase(repository: repository),
            getLaunchAtLoginStatus: GetLaunchAtLoginStatusUseCase(service: launchAtLogin),
            setLaunchAtLogin: SetLaunchAtLoginUseCase(service: launchAtLogin),
            getAppVersion: GetAppVersionUseCase(provider: versionProvider),
            languageApplier: languageApplier,
            appearanceApplier: appearanceApplier
        )
    }
}
