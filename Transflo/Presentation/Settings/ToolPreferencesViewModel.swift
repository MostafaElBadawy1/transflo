import Observation
import TransfloDomain

/// Persists instant-tool defaults and naming through the Repository boundary.
@Observable
final class ToolPreferencesViewModel {
    private(set) var choice: CompressionChoice
    private(set) var targetMegabytes: Double
    private(set) var nameStyle: ToolNameStyle
    @ObservationIgnored private let repository: any ToolPreferencesRepository

    init(repository: any ToolPreferencesRepository) {
        self.repository = repository
        let goal = repository.loadCompressionGoal()
        choice = CompressionChoice(goal)
        if case .targetBytes(let bytes) = goal {
            targetMegabytes = min(1000, max(0.1, Double(bytes) / 1_000_000))
        } else {
            targetMegabytes = 1
        }
        nameStyle = repository.loadNameStyle()
    }

    func select(_ choice: CompressionChoice) {
        self.choice = choice
        saveGoal()
    }

    func setTargetMegabytes(_ value: Double) {
        guard value.isFinite, value > 0 else { return }
        targetMegabytes = min(1000, max(0.1, value))
        if choice == .target { saveGoal() }
    }

    func selectNameStyle(_ style: ToolNameStyle) {
        nameStyle = style
        repository.saveNameStyle(style)
    }

    private func saveGoal() {
        repository.saveCompressionGoal(choice.goal(megabytes: targetMegabytes))
    }
}
