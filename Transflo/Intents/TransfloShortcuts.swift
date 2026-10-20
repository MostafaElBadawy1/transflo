import AppIntents

/// Phrases that offer Transflo's actions in Spotlight, Siri and the Shortcuts app with no setup.
struct TransfloShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: ConvertFilesIntent(), phrases: ["Convert files with \(.applicationName)"],
                    shortTitle: LocalizedStringResource("intent.convert.short", defaultValue: "Convert Files"),
                    systemImageName: "arrow.triangle.2.circlepath")
        AppShortcut(intent: CompressFilesIntent(), phrases: ["Compress files with \(.applicationName)"],
                    shortTitle: LocalizedStringResource("intent.compress.short", defaultValue: "Compress Files"),
                    systemImageName: "arrow.down.right.and.arrow.up.left")
        AppShortcut(intent: RunRecipeIntent(), phrases: ["Run a \(.applicationName) recipe"],
                    shortTitle: LocalizedStringResource("intent.recipe.short", defaultValue: "Run Recipe"),
                    systemImageName: "wand.and.rays")
    }
}
