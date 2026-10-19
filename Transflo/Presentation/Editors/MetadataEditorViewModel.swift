import Foundation
import Observation
import TransfloDomain

/// Edit metadata: title, author and comment, prefilled with what the file carries now.
@Observable
final class MetadataEditorViewModel: ToolEditorModel {
    private(set) var isLoaded = false
    var title = ""
    var author = ""
    var comment = ""
    @ObservationIgnored private var original: [MetadataField: String] = [:]

    @ObservationIgnored private let item: URL
    @ObservationIgnored private let format: FormatDescriptor?
    @ObservationIgnored private let reader: any ToolMetadataReading

    init(item: URL, format: FormatDescriptor?, reader: any ToolMetadataReading) {
        self.item = item
        self.format = format
        self.reader = reader
    }

    var fileName: String { item.lastPathComponent }

    /// Only the fields that differ from the file; an emptied field clears it.
    var changes: [MetadataField: String] {
        let current: [MetadataField: String] = [.title: title, .author: author, .comment: comment]
        return current.reduce(into: [:]) { result, entry in
            let value = entry.value.trimmingCharacters(in: .whitespacesAndNewlines)
            if value != original[entry.key, default: ""] { result[entry.key] = value }
        }
    }

    var settings: ToolSettings? {
        guard isLoaded, !changes.isEmpty else { return nil }
        return .metadata(changes)
    }

    func load() async {
        original = await reader.metadata(of: item, format: format)
        title = original[.title, default: ""]
        author = original[.author, default: ""]
        comment = original[.comment, default: ""]
        isLoaded = true
    }
}
