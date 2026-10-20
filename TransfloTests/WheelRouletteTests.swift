import Testing
@testable import Transflo
import TransfloDomain

@Suite("Wheel in Russian Roulette mode")
struct WheelRouletteTests {
    /// Six options: chamber centers 100 from the middle, 60° apart; chamber 3 sits at 6 o'clock.
    private let options = ActionKind.allCases.map { WheelOption(.action($0)) }
    private let firingHole = WheelPoint(x: 0, y: 100)
    private let bottomChamber = WheelPoint(x: 0, y: -100)
    private let hub = WheelPoint(x: 0, y: 0)

    private final class Turns {
        var steps: [Int] = []
    }

    private func makeSUT(enabled: Bool = true, aimDelay: Duration = .zero, turns: Turns = Turns()) -> WheelViewModel {
        WheelViewModel(
            bindings: .standard,
            layout: StubLayoutDirection(),
            sizing: .fixed(innerRadius: 50, outerRadius: 150),
            roulette: WheelRoulette(isEnabled: { enabled }, aimDelay: aimDelay, onTurn: { turns.steps.append($0) })
        )
    }

    @Test("with the mode off there is no cylinder and the plain wheel behaves as before")
    func off() {
        let sut = makeSUT(enabled: false)
        sut.show(.actions, options: options)
        #expect(sut.state.cylinder == nil && sut.state.highlightedIndex == nil)
        #expect(sut.updatePointer(bottomChamber))
        #expect(sut.state.highlightedIndex == 3)
        #expect(sut.option(at: bottomChamber) == options[3])
    }

    @Test("a cylinder opens with the first chamber in the firing position")
    func opens() {
        let sut = makeSUT()
        sut.show(.actions, options: options)
        #expect(sut.state.cylinder?.selectedIndex == 0)
        #expect(sut.state.highlightedIndex == 0)
        #expect(sut.option(at: firingHole) == options[0])
    }

    @Test("resting on a chamber turns it to the top; only the firing hole takes the drop")
    func aims() {
        let turns = Turns()
        let sut = makeSUT(turns: turns)
        sut.show(.actions, options: options)
        #expect(!sut.updatePointer(bottomChamber))
        #expect(sut.state.highlightedIndex == 3 && sut.state.cylinder?.selectedIndex == 3)
        #expect(turns.steps == [3])
        #expect(sut.option(at: bottomChamber) == nil)
        #expect(sut.option(at: hub) == nil)
        #expect(sut.updatePointer(firingHole))
        #expect(sut.option(at: firingHole) == options[3])
    }

    @Test("staying on the same sector after the turn doesn't turn the cylinder again")
    func noFeedbackLoop() {
        let turns = Turns()
        let sut = makeSUT(turns: turns)
        sut.show(.actions, options: options)
        sut.updatePointer(bottomChamber)
        sut.updatePointer(WheelPoint(x: 5, y: -110))
        sut.updatePointer(firingHole)
        #expect(turns.steps == [3])
    }

    @Test("passing over chambers on the way to the firing hole doesn't aim them")
    func aimWaitsForRest() async throws {
        let turns = Turns()
        let sut = makeSUT(aimDelay: .milliseconds(80), turns: turns)
        sut.show(.actions, options: options)
        sut.updatePointer(bottomChamber)
        #expect(sut.updatePointer(firingHole))
        try await Task.sleep(for: .milliseconds(200))
        #expect(turns.steps.isEmpty && sut.state.highlightedIndex == 0)
    }

    @Test("resting on a chamber aims it once the delay passes")
    func aimAfterRest() async throws {
        let turns = Turns()
        let sut = makeSUT(aimDelay: .milliseconds(20), turns: turns)
        sut.show(.actions, options: options)
        sut.updatePointer(bottomChamber)
        sut.updatePointer(WheelPoint(x: 3, y: -105))
        try await Task.sleep(for: .milliseconds(200))
        #expect(turns.steps == [3] && sut.state.highlightedIndex == 3)
    }

    @Test("arrow keys turn the cylinder one chamber at a time")
    func keys() {
        let turns = Turns()
        let sut = makeSUT(turns: turns)
        sut.show(.actions, options: options)
        sut.stepHighlight(clockwise: true)
        sut.stepHighlight(clockwise: false)
        sut.stepHighlight(clockwise: false)
        #expect(turns.steps == [1, -1, -1])
        #expect(sut.state.highlightedIndex == 5)
        #expect(sut.activateHighlighted() == options[5])
    }

    @Test("once fired the cylinder ignores the pointer and takes no drop")
    func fired() {
        let turns = Turns()
        let sut = makeSUT(turns: turns)
        sut.show(.actions, options: options)
        sut.fire(.hit)
        #expect(sut.state.shot == .hit)
        #expect(!sut.updatePointer(firingHole))
        sut.updatePointer(bottomChamber)
        #expect(turns.steps.isEmpty)
        #expect(sut.option(at: firingHole) == nil)
        sut.reset()
        #expect(sut.state.shot == nil && sut.state.cylinder == nil)
    }

    @Test("More in the firing position takes no drop, and a page turn reloads the cylinder")
    func paging() {
        let sut = makeSUT()
        sut.show(.convert, options: ToolKind.allCases.map { WheelOption(.tool($0)) })
        let more = sut.state.slots.firstIndex(of: .more) ?? -1
        #expect(sut.state.cylinder?.geometry.wedgeCount == 12)
        sut.stepHighlight(clockwise: false)
        #expect(sut.state.highlightedIndex == more)
        #expect(!sut.updatePointer(firingHole))
        sut.turnPage()
        #expect(sut.state.page == 1 && sut.state.cylinder?.selectedIndex == 0 && sut.state.cylinder?.turns == 0)
    }
}
