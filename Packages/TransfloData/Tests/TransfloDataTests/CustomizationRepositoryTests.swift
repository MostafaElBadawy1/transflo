import Foundation
import Testing
@testable import TransfloData
import TransfloDomain

@Suite("Customization storage")
struct CustomizationRepositoryTests {
    @Test("customization survives reopening and does not change language or appearance")
    func persistence() throws {
        let name = "CustomizationTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let repository = UserDefaultsSettingsRepository(defaults: defaults)
        #expect(repository.loadCustomization() == nil)
        repository.saveLanguage(.arabic)
        repository.saveAppearance(.dark)
        let value = InterfaceCustomization(accentHex: "aabbcc", wheelSize: .large,
                                           solidSurfaces: true, reduceMotion: true)
        repository.saveCustomization(value)
        let reopened = UserDefaultsSettingsRepository(defaults: defaults)
        #expect(reopened.loadCustomization() == value)
        repository.saveCustomization(.standard)
        #expect(reopened.loadCustomization() == .standard)
        #expect(reopened.loadAppearance() == .dark)
        #expect(reopened.loadLanguage() == .arabic)
    }

    @Test("invalid data falls back safely and malformed RGB values never reach the renderer")
    func malformedValues() throws {
        let name = "CustomizationTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let repository = UserDefaultsSettingsRepository(defaults: defaults)
        defaults.set(Data("not json".utf8), forKey: SettingsStorageKey.customization)
        #expect(repository.loadCustomization() == nil)
        var preferences = InterfaceCustomization.standard
        preferences.accentHex = "FFFFFFjunk"
        repository.saveCustomization(preferences)
        #expect(repository.loadCustomization()?.accentHex == nil)
    }
}
