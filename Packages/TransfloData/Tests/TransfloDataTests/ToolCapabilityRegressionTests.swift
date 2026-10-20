import Testing
@testable import TransfloData
import TransfloDomain

@Suite("Tool capability regressions")
struct ToolCapabilityRegressionTests {
    @Test("PNG background removal works without a WebP output encoder")
    func backgroundRemovalDoesNotRequireSourceEncoder() {
        let engine = ImageToolEngine(ffmpeg: nil, naming: MediaToolTests.naming, copier: SpyCopier())
        let webp = MatrixConversionTests.catalog.format(FormatID("webp"))
        #expect(engine.canRun(.removeBackground, on: [webp]))
        #expect(!engine.canRun(.adjust, on: [webp]))
        #expect(!engine.canRun(.removeBackground, on: [nil]))
        #expect(!engine.canRun(.removeBackground, on: []))
    }
}
