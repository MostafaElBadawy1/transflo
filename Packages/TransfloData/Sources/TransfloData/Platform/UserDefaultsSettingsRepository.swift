import Foundation
import TransfloDomain

// @unchecked: `UserDefaults` is documented as thread-safe but is not annotated `Sendable` in the SDK.
/// `SettingsRepository` backed by `UserDefaults`. These values are not sensitive.
public struct UserDefaultsSettingsRepository: SettingsRepository, WheelVisibilityRepository, @unchecked Sendable {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public func loadHasCompletedOnboarding() -> Bool {
        defaults.bool(forKey: SettingsStorageKey.onboardingCompleted)
    }

    public func saveHasCompletedOnboarding(_ completed: Bool) {
        defaults.set(completed, forKey: SettingsStorageKey.onboardingCompleted)
    }

    public func loadLanguage() -> AppLanguage? {
        SettingsMapper.language(fromStorage: defaults.string(forKey: SettingsStorageKey.language))
    }

    public func saveLanguage(_ language: AppLanguage) {
        defaults.set(SettingsMapper.storageValue(for: language), forKey: SettingsStorageKey.language)
    }

    public func loadAppearance() -> AppearanceMode? {
        SettingsMapper.appearance(fromStorage: defaults.string(forKey: SettingsStorageKey.appearance))
    }

    public func saveAppearance(_ appearance: AppearanceMode) {
        defaults.set(SettingsMapper.storageValue(for: appearance), forKey: SettingsStorageKey.appearance)
    }

    public func loadCustomization() -> InterfaceCustomization? {
        guard let data = defaults.data(forKey: SettingsStorageKey.customization) else { return nil }
        return (try? JSONDecoder().decode(InterfaceCustomization.self, from: data))?.validated
    }

    public func saveCustomization(_ customization: InterfaceCustomization) {
        guard let data = try? JSONEncoder().encode(customization.validated) else { return }
        defaults.set(data, forKey: SettingsStorageKey.customization)
    }
    public func loadCompressionGoal() -> CompressionGoal {
        guard let data = defaults.data(forKey: SettingsStorageKey.compressionGoal),
              let goal = try? JSONDecoder().decode(CompressionGoal.self, from: data) else { return .medium }
        if case .targetBytes(let bytes) = goal, !(100_000...1_000_000_000).contains(bytes) { return .medium }
        return goal
    }

    public func saveCompressionGoal(_ goal: CompressionGoal) {
        guard let data = try? JSONEncoder().encode(goal) else { return }
        defaults.set(data, forKey: SettingsStorageKey.compressionGoal)
    }

    public func loadNameStyle() -> ToolNameStyle {
        ToolNameStyle(rawValue: defaults.string(forKey: SettingsStorageKey.nameStyle) ?? "") ?? .parentheses
    }

    public func saveNameStyle(_ style: ToolNameStyle) {
        defaults.set(style.rawValue, forKey: SettingsStorageKey.nameStyle)
    }

    public func loadWheelVisibility() -> WheelVisibility {
        guard let data = defaults.data(forKey: SettingsStorageKey.wheelVisibility),
              let visibility = try? JSONDecoder().decode(WheelVisibility.self, from: data) else { return .standard }
        return visibility
    }

    public func saveWheelVisibility(_ visibility: WheelVisibility) {
        guard let data = try? JSONEncoder().encode(visibility) else { return }
        defaults.set(data, forKey: SettingsStorageKey.wheelVisibility)
    }
}
