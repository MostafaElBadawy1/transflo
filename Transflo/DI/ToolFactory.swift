import Foundation
import os
import TransfloData
import TransfloDomain
import TransfloSystem

/// Builds the tool engines and the tool catalog restricted to what they can run.
struct ToolFactory {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.transflo.app",
        category: "Tools"
    )

    let engines: [any ToolEngine]
    let catalog: ToolCatalog
    let previews: any ToolPreviewProviding
    let metadata: any ToolMetadataReading
    private let formats: ConversionCatalog

    init(
        formats: ConversionCatalog,
        suffixes: any ToolSuffixProviding,
        loader: any ToolCatalogLoading = BundledToolCatalogLoader(),
        bundle: Bundle = .main,
        nameStyle: (any ToolNameStyleProviding)? = nil
    ) {
        let files = NameOutputFileUseCase(checker: FileManagerExistenceChecker())
        let naming = ToolOutputNaming(naming: files, suffixes: suffixes, style: nameStyle)
        let ffmpeg = FFmpegEngine.bundledBinary(in: bundle)
        let ffprobe = FFmpegEngine.bundledProbe(in: bundle)
        previews = MediaToolPreviewProvider(ffmpeg: ffmpeg, ffprobe: ffprobe)
        metadata = FileMetadataReader(ffprobe: ffprobe)
        engines = [
            ImageToolEngine(ffmpeg: ffmpeg, naming: naming, copier: PasteboardTextCopier()),
            MediaToolEngine(ffmpeg: ffmpeg, ffprobe: ffprobe, naming: naming),
            PDFToolEngine(naming: naming),
            FileToolEngine(naming: files)
        ]
        self.formats = formats
        do {
            catalog = try loader.load().restricted(to: engines, formats: formats.formats)
        } catch {
            Self.logger.fault("Tool catalog unavailable: \(String(describing: error), privacy: .public)")
            catalog = ToolCatalog(tools: [])
        }
    }

    func makeEditors(formats: ConversionCatalog, localizer: Localizer) -> ToolEditorCoordinator {
        ToolEditorCoordinator(formats: formats, previews: previews, metadata: metadata, localizer: localizer,
                              backgroundRenderer: BackgroundPreviewRenderer())
    }

    func makeRunner() -> ToolJobRunner {
        ToolJobRunner(formats: formats, engines: engines)
    }
}
