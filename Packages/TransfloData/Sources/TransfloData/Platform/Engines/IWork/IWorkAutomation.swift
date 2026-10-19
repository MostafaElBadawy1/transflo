import Foundation
import os
import TransfloDomain

/// Runs an iWork export through `osascript` and maps its failures.
enum IWorkAutomation {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.transflo.app",
        category: "iWork"
    )
    static let notAuthorized = "-1743"

    static func export(_ input: URL, with app: IWorkApp, kind: String, to output: URL) async throws(JobError) {
        guard app.exportKinds.contains(kind) else { throw .unsupported }
        let errors = Collector()
        let arguments = app.script.flatMap { ["-e", $0] } + [input.path, output.path, kind]
        let status = await ProcessRunner.run(
            executable: URL(fileURLWithPath: "/usr/bin/osascript"),
            arguments: arguments,
            onStdoutLine: { _ in },
            onStderrLine: errors.append
        )
        if Task.isCancelled { throw .cancelled }
        guard let status else { throw .unsupported }
        guard status == 0 else { throw error(from: errors.lines) }
    }

    static func error(from stderr: [String]) -> JobError {
        let message = stderr.joined(separator: " ")
        logger.error("iWork export failed: \(message, privacy: .private)")
        return message.contains(notAuthorized) ? .automationDenied : .failed
    }
}
