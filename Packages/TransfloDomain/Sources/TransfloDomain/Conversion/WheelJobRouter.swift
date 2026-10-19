import Foundation

/// Sends each wedge to the runner that implements it.
///
/// Format wedges go to conversion, tool wedges to the tool runner and action wedges to the
/// action runner.
public struct WheelJobRouter: WheelJobRunning {
    private let conversion: any WheelJobRunning
    private let tools: any WheelJobRunning
    private let actions: any WheelJobRunning

    public init(conversion: any WheelJobRunning, tools: any WheelJobRunning, actions: any WheelJobRunning) {
        self.conversion = conversion
        self.tools = tools
        self.actions = actions
    }

    public func run(
        _ option: WheelOption,
        on items: [URL],
        progress: @escaping @Sendable (Double) -> Void
    ) async throws(JobError) -> [URL] {
        switch option.kind {
        case .format: try await conversion.run(option, on: items, progress: progress)
        case .tool: try await tools.run(option, on: items, progress: progress)
        case .action: try await actions.run(option, on: items, progress: progress)
        }
    }
}
