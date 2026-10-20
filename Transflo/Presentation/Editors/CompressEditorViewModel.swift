import Foundation
import Observation
import TransfloDomain

/// Per-drop compression choices. Percentage budgets are resolved separately for each source.
@Observable
final class CompressEditorViewModel: ToolEditorModel {
    enum Mode: Hashable { case preset, fileSize, percentage }
    enum ImageSize: Int, Hashable { case original = 0, small = 1280, medium = 1920, large = 2560, custom = -1 }
    var mode: Mode = .preset
    var level: CompressionLevel = .medium
    var megabytes = 1.0
    var percentage = 50
    var imageSize: ImageSize = .original
    var customLongEdge = 2048
    private(set) var originalBytes: Int64?
    private(set) var isLoaded = false
    let itemCount: Int
    let fileName: String?
    let isImage: Bool
    let supportsBudget: Bool
    @ObservationIgnored private let items: [URL]
    @ObservationIgnored private let size: (URL) -> Int64?

    init(
        items: [URL],
        formats: [FormatDescriptor?],
        initialGoal: CompressionGoal = .medium,
        size: @escaping (URL) -> Int64? = { url in
            (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init)
        }
    ) {
        self.items = items
        self.size = size
        itemCount = items.count
        fileName = items.count == 1 ? items.first?.lastPathComponent : nil
        isImage = !formats.isEmpty && formats.allSatisfy { $0?.family == .image }
        supportsBudget = !formats.contains { $0?.id.rawValue == "pdf" }
        switch initialGoal {
        case .level(let value): level = value
        case .targetBytes(let bytes): mode = .fileSize; megabytes = Double(bytes) / 1_000_000
        case .percentage(let value): mode = .percentage; percentage = value
        }
        if !supportsBudget { mode = .preset; level = .medium }
    }

    var goal: CompressionGoal? {
        switch mode {
        case .preset: .level(level)
        case .fileSize:
            megabytes.isFinite && (0.01...1000).contains(megabytes)
                ? .targetBytes(Int64(megabytes * 1_000_000)) : nil
        case .percentage: (1...99).contains(percentage) ? .percentage(percentage) : nil
        }
    }

    var settings: ToolSettings? {
        guard isLoaded, !items.isEmpty, let goal, supportsBudget || mode == .preset else { return nil }
        if mode == .percentage && originalBytes == nil { return nil }
        if isImage {
            let edge: Int? = imageSize == .original ? nil
                : (imageSize == .custom ? customLongEdge : imageSize.rawValue)
            if let edge, !(1...16_384).contains(edge) { return nil }
            return .compressImage(goal: goal, maximumLongEdge: edge)
        }
        return .compress(goal)
    }

    var estimatedTargetBytes: Int64? {
        guard let originalBytes else { return nil }
        if mode == .fileSize, let budget = goal?.byteBudget(originalBytes: originalBytes) {
            let (total, overflow) = budget.multipliedReportingOverflow(by: Int64(itemCount))
            return overflow ? nil : total
        }
        return goal?.byteBudget(originalBytes: originalBytes)
    }

    func load() async {
        var total: Int64 = 0
        for item in items {
            guard let bytes = size(item), bytes >= 0 else { isLoaded = true; return }
            let (next, overflow) = total.addingReportingOverflow(bytes)
            guard !overflow else { isLoaded = true; return }
            total = next
        }
        originalBytes = total
        isLoaded = true
    }
}
