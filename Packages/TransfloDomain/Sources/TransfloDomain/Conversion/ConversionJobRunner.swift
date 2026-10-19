import Foundation

/// Runs Convert-wheel jobs: resolves each file's path, picks an engine, names the output,
/// converts, and preserves completed results when a later item fails.
public struct ConversionJobRunner: WheelJobRunning {
    private let catalog: ConversionCatalog
    private let engines: [EngineID: any ConversionEngine]
    private let naming: NameOutputFileUseCase

    public init(
        catalog: ConversionCatalog,
        engines: [any ConversionEngine],
        naming: NameOutputFileUseCase,
        remover: any FileRemoving
    ) {
        self.catalog = catalog
        self.engines = Dictionary(engines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        self.naming = naming
        // Engines own and clean private staging; final paths may belong to another writer.
    }

    public func run(
        _ option: WheelOption,
        on items: [URL],
        progress: @escaping @Sendable (Double) -> Void
    ) async throws(JobError) -> [URL] {
        guard case .format(let target) = option.kind else { throw .unsupported }
        var outputs: [URL] = []
        do throws(JobError) {
            for (index, source) in items.enumerated() {
                if Task.isCancelled { throw .cancelled }
                let request = try makeRequest(source: source, target: target)
                let engine = try engine(for: request)
                let share = 1 / Double(items.count)
                let base = Double(index) * share
                outputs += try await engine.convert(request) { fraction in
                    progress(base + min(max(fraction, 0), 1) * share)
                }
            }
        } catch {
            throw outputs.isEmpty ? error : .partialFailure(completed: outputs, cause: error)
        }
        progress(1)
        return outputs
    }

    private func makeRequest(source: URL, target: FormatDescriptor) throws(JobError) -> ConversionRequest {
        guard let sourceFormat = catalog.format(forFileExtension: source.pathExtension) else { throw .unsupported }
        let destination = try naming.execute(for: source, pathExtension: target.outputExtension)
        return ConversionRequest(
            source: source,
            destination: destination,
            sourceFormat: sourceFormat,
            targetFormat: target
        )
    }

    private func engine(for request: ConversionRequest) throws(JobError) -> any ConversionEngine {
        guard let path = catalog.path(from: request.sourceFormat.id, to: request.targetFormat.id) else {
            throw .unsupported
        }
        let candidate = path.engines.lazy
            .compactMap { engines[$0] }
            .first { $0.canConvert(from: request.sourceFormat, to: request.targetFormat) }
        guard let candidate else { throw .unsupported }
        return candidate
    }
}
