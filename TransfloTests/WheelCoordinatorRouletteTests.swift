import Foundation
import Testing
@testable import Transflo
import TransfloDomain
import TransfloDomainTestSupport

@Suite("WheelCoordinator in Russian Roulette mode")
struct WheelCoordinatorRouletteTests {
    private let file = URL(fileURLWithPath: "/tmp/photo.heic")
    private let point = WheelPoint(x: 500, y: 400)
    private let firingHole = WheelPoint(x: 0, y: 100)
    /// Chamber 1 of two sits at 6 o'clock.
    private let otherChamber = WheelPoint(x: 0, y: -100)
    private static let formats = [CatalogFixtures.png, CatalogFixtures.jpg].map { WheelOption(.format($0)) }

    private struct Harness {
        let presenter = SpyWheelPresenter()
        let scheduler = SpyJobScheduler()
        let roulette = SpyRouletteFiring()
        let viewModel: WheelViewModel
        let sut: WheelCoordinator

        init(enabled: Bool = true, shotHold: Duration = .seconds(10)) {
            viewModel = WheelViewModel(
                bindings: .standard,
                layout: StubLayoutDirection(),
                sizing: .fixed(innerRadius: 50, outerRadius: 150),
                roulette: WheelRoulette(isEnabled: { enabled }, aimDelay: .zero)
            )
            sut = WheelCoordinator(
                resolveOptions: ResolveWheelOptionsUseCase(provider: StubWheelOptionsProvider([
                    .convert: WheelCoordinatorRouletteTests.formats, .actions: [], .tools: []
                ])),
                presenter: presenter,
                viewModel: viewModel,
                scheduler: scheduler,
                editor: SpyToolEditor(),
                preparer: SpyActionPreparer(),
                dismissDelay: .seconds(10),
                roulette: roulette,
                shotHold: shotHold
            )
        }

        func open(at point: WheelPoint) {
            sut.handle(.began(items: [URL(fileURLWithPath: "/tmp/photo.heic")]))
            sut.handle(.wheelRequested(.convert, at: point))
        }
    }

    @Test("a cylinder loads its sounds when it opens; the plain wheel doesn't")
    func prepares() {
        let enabled = Harness()
        enabled.open(at: point)
        #expect(enabled.roulette.prepareCount == 1)
        let disabled = Harness(enabled: false)
        disabled.open(at: point)
        #expect(disabled.roulette.prepareCount == 0)
    }

    @Test("a drop on the firing hole fires, schedules the job at once, and leaves the cylinder up")
    func fires() {
        let harness = Harness()
        harness.roulette.outcome = .hit
        harness.open(at: point)
        _ = harness.presenter.onHover?(otherChamber)
        #expect(harness.presenter.onDrop?(firingHole) == true)
        #expect(harness.roulette.firedChamberCounts == [2])
        #expect(harness.scheduler.scheduled == [.init(option: Self.formats[1], items: [file], point: point)])
        #expect(harness.viewModel.state.shot == .hit)
        #expect(harness.presenter.hideCount == 0)
    }

    @Test("a drop anywhere but the firing hole does nothing and closes")
    func dropElsewhere() {
        let harness = Harness()
        harness.open(at: point)
        #expect(harness.presenter.onDrop?(otherChamber) == false)
        #expect(harness.scheduler.scheduled.isEmpty && harness.roulette.firedChamberCounts.isEmpty)
        #expect(harness.presenter.hideCount == 1)
    }

    @Test("the cylinder closes after the hold, or at once when a new drag starts")
    func linger() async throws {
        let held = Harness(shotHold: .milliseconds(20))
        held.open(at: point)
        _ = held.presenter.onDrop?(firingHole)
        try await Task.sleep(for: .milliseconds(200))
        #expect(held.presenter.hideCount == 1 && held.viewModel.state.kind == nil)

        let interrupted = Harness()
        interrupted.open(at: point)
        _ = interrupted.presenter.onDrop?(firingHole)
        interrupted.open(at: point)
        #expect(interrupted.presenter.hideCount == 1)
        #expect(interrupted.viewModel.state.kind == .convert && interrupted.viewModel.state.shot == nil)
        #expect(interrupted.presenter.shownAt == [point, point])
    }

    @Test("keyboard mode: clicking a chamber aims it without closing; clicking the firing hole fires")
    func clicks() {
        let harness = Harness()
        #expect(harness.sut.openForKeyboard(items: [file], at: point))
        harness.presenter.onPointer?(otherChamber)
        #expect(harness.presenter.onClick?(otherChamber) == true)
        #expect(harness.presenter.hideCount == 0 && harness.viewModel.state.highlightedIndex == 1)
        #expect(harness.presenter.onClick?(firingHole) == true)
        #expect(harness.scheduler.scheduled.map(\.option) == [Self.formats[1]])
        #expect(harness.roulette.firedChamberCounts == [2])
    }

    @Test("with the mode off, drops never pull the trigger")
    func off() {
        let harness = Harness(enabled: false)
        harness.open(at: point)
        #expect(harness.presenter.onDrop?(firingHole) == true)
        #expect(harness.roulette.firedChamberCounts.isEmpty)
        #expect(harness.presenter.hideCount == 1)
        #expect(harness.scheduler.scheduled.map(\.option) == [Self.formats[0]])
    }
}
