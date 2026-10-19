import Foundation
import Testing
@testable import Transflo
import TransfloDomain
import TransfloDomainTestSupport

struct ToolPreferencesViewModelTests {
    @Test func persistsCompressionChoicesAndValidatedBudgets() {
        let repository = InMemoryToolPreferences()
        let model = ToolPreferencesViewModel(repository: repository)
        #expect(model.choice == .medium)
        model.select(.target)
        model.setTargetMegabytes(1.5)
        #expect(repository.loadCompressionGoal() == .targetBytes(1_500_000))
        model.setTargetMegabytes(.nan)
        model.setTargetMegabytes(-1)
        #expect(model.targetMegabytes == 1.5)
        model.setTargetMegabytes(2000)
        #expect(model.targetMegabytes == 1000)
        model.select(.light)
        #expect(repository.loadCompressionGoal() == .light)
        model.select(.medium)
        #expect(repository.loadCompressionGoal() == .medium)
        model.select(.strong)
        #expect(repository.loadCompressionGoal() == .strong)
        model.selectNameStyle(.word)
        #expect(repository.loadNameStyle() == .word)
        #expect(ToolPreferencesViewModel(repository: repository).nameStyle == .word)
    }

    @Test func restoresFractionalMegabytes() {
        let repository = InMemoryToolPreferences(goal: .targetBytes(250_000))
        let model = ToolPreferencesViewModel(repository: repository)
        #expect(model.choice == .target && model.targetMegabytes == 0.25)
    }
    @Test func unchangedOriginalHasAnExplicitCompletionMessage() {
        let record = JobRecord(id: UUID(), option: WheelOption(.tool(.compress)), items: [],
                               origin: WheelPoint(x: 0, y: 0), state: .succeeded(outputs: []),
                               originalWithinTarget: true)
        #expect(JobPresentation.title(for: record).key == .hudWithinTarget)
        #expect(JobPresentation.message(for: .targetUnreachable) == .errorTargetUnreachable)
    }
}
