import Foundation
import TransfloDomain

/// One scheduled wheel job and its current state.
struct JobRecord: Identifiable, Equatable {
    let id: UUID
    let option: WheelOption
    let items: [URL]
    /// Where the files were dropped (screen space); the HUD appears next to it.
    let origin: WheelPoint
    var state: JobState
    var originalWithinTarget = false

    var completedOutputs: [URL] {
        switch state {
        case .succeeded(let outputs): outputs
        case .failed(let error): error.completedOutputs
        case .queued, .running: []
        }
    }
}
