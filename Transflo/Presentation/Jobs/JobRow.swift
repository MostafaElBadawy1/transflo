import Foundation

/// One line of the Jobs window: what the job does, on which files, and where it stands.
struct JobRow: Identifiable, Equatable {
    let id: UUID
    let operation: AppTextContent
    let files: AppTextContent
    let status: AppTextContent
    let ring: AppProgressRing.Status
    let canCancel: Bool
    let canReveal: Bool
    let isFailed: Bool

    init(_ record: JobRecord) {
        id = record.id
        operation = JobPresentation.operation(for: record.option)
        files = record.items.count == 1
            ? .verbatim(record.items[0].lastPathComponent)
            : .formatted(.jobFileCount, [String(record.items.count)])
        status = JobPresentation.listStatus(for: record)
        ring = JobPresentation.ring(for: record.state)
        canCancel = !record.state.isFinished
        canReveal = !record.completedOutputs.isEmpty
        if case .failed = record.state { isFailed = true } else { isFailed = false }
    }
}
