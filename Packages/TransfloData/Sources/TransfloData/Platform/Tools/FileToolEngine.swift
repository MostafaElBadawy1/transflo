import Foundation
import TransfloDomain

/// Rename with pattern: renames the dropped files in place (the one tool that changes originals'
/// names, never their contents), avoiding collisions.
public struct FileToolEngine: ToolEngine {
    private let naming: NameOutputFileUseCase

    public init(naming: NameOutputFileUseCase) {
        self.naming = naming
    }

    public func canRun(_ tool: ToolKind, on formats: [FormatDescriptor?]) -> Bool {
        tool == .rename && !formats.isEmpty
    }

    public func run(
        _ request: ToolRequest,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws(JobError) -> [URL] {
        try await BlockingWork.runCancellable { [self] isCancelled throws(JobError) -> [URL] in
            try rename(request, isCancelled: isCancelled)
        }
    }

    private func rename(_ request: ToolRequest, isCancelled: () -> Bool) throws(JobError) -> [URL] {
        guard case let .rename(pattern, start) = request.settings else { throw .unsupported }
        let urls = request.items.map(\.url)
        let names = RenamePattern.names(pattern, originals: urls.map { $0.deletingPathExtension().lastPathComponent },
                                        start: start)
        var renamed: [URL] = []
        do throws(JobError) {
            for (url, name) in zip(urls, names) {
                if isCancelled() { throw .cancelled }
                guard FileManager.default.fileExists(atPath: url.path) else { throw .sourceMissing }
                var candidate = url.deletingLastPathComponent().appendingPathComponent(name)
                if !url.pathExtension.isEmpty { candidate.appendPathExtension(url.pathExtension) }
                guard candidate.standardizedFileURL != url.standardizedFileURL else {
                    renamed.append(url)
                    continue
                }
                let destination = try naming.execute(for: candidate, pathExtension: nil)
                do {
                    try FileManager.default.moveItem(at: url, to: destination)
                } catch {
                    throw .destinationUnavailable
                }
                renamed.append(destination)
            }
        } catch {
            throw renamed.isEmpty ? error : .partialFailure(completed: renamed, cause: error)
        }
        return renamed
    }
}
