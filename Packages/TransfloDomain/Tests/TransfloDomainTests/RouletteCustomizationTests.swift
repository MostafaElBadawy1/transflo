import Foundation
import Testing
import TransfloDomain

struct RouletteCustomizationTests {
    @Test("Russian Roulette mode is off and unmuted by default and in older preference files")
    func defaultsOff() throws {
        #expect(!InterfaceCustomization.standard.rouletteMode && !InterfaceCustomization.standard.rouletteSoundsMuted)
        let json = #"{"accentHex":"ABCDEF","wheelSize":"large","wheelHaptics":false,"wheelSound":true}"#
        let value = try JSONDecoder().decode(InterfaceCustomization.self, from: Data(json.utf8))
        #expect(!value.rouletteMode && !value.rouletteSoundsMuted)
        #expect(value.accentHex == "ABCDEF" && value.wheelSize == .large && !value.wheelHaptics)
    }

    @Test("the roulette flags persist and survive validation")
    func roundTrip() throws {
        var value = InterfaceCustomization.standard
        value.rouletteMode = true
        value.rouletteSoundsMuted = true
        let reopened = try JSONDecoder().decode(InterfaceCustomization.self, from: JSONEncoder().encode(value))
        #expect(reopened.rouletteMode && reopened.rouletteSoundsMuted)
        #expect(reopened.validated == reopened)
    }
}
