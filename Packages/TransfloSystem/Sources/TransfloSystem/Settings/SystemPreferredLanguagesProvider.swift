import Foundation
import TransfloDomain

/// Reads the user's preferred languages from macOS.
public struct SystemPreferredLanguagesProvider: PreferredLanguagesProviding {
    public init() {}

    public var preferredLanguageCodes: [String] {
        Locale.preferredLanguages
    }
}
