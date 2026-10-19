import Foundation
import Observation

/// The Jobs window: recent jobs newest first, with per-job and bulk actions.
@Observable
final class JobListViewModel {
    @ObservationIgnored private let jobCenter: JobCenter

    init(jobCenter: JobCenter) {
        self.jobCenter = jobCenter
    }

    var rows: [JobRow] { jobCenter.jobs.reversed().map(JobRow.init) }
    var hasActiveJobs: Bool { jobCenter.jobs.contains { !$0.state.isFinished } }
    var hasFinishedJobs: Bool { jobCenter.jobs.contains { $0.state.isFinished } }

    func cancel(_ id: UUID) {
        jobCenter.cancel(id)
    }

    func reveal(_ id: UUID) {
        jobCenter.reveal(id)
    }

    func cancelAll() {
        jobCenter.cancelAll()
    }

    func clearFinished() {
        jobCenter.clearFinished()
    }
}
