import Testing
@testable import Transflo
import TransfloDomain

@Suite("CylinderAim")
struct CylinderAimTests {
    private func makeSUT(count: Int = 6, rtl: Bool = false) -> CylinderAim {
        CylinderAim(geometry: WheelGeometry(wedgeCount: count, innerRadius: 50, outerRadius: 150, isRightToLeft: rtl))
    }

    @Test("the short way round is signed, and a half turn goes forward", arguments: [
        (0, 1, 6, 1), (0, 5, 6, -1), (1, 4, 6, 3), (4, 1, 6, 3), (2, 2, 6, 0), (0, 4, 7, -3), (0, 3, 7, 3), (0, 0, 0, 0)
    ])
    func shortestSteps(from: Int, to: Int, count: Int, expected: Int) {
        #expect(CylinderAim.shortestSteps(from: from, to: to, count: count) == expected)
    }

    @Test("turning brings the chamber to the top and accumulates turns past a full revolution")
    func turn() {
        var sut = makeSUT()
        #expect(sut.selectedIndex == 0 && sut.rotationDegrees == 0)
        #expect(sut.turn(to: 2) == 2)
        #expect(sut.selectedIndex == 2 && sut.rotationDegrees == -120)
        #expect(sut.turn(to: 5) == 3)
        #expect(sut.turn(to: 1) == 2)
        #expect(sut.selectedIndex == 1 && sut.turns == 7)
        #expect(sut.turn(to: 1) == 0)
    }

    @Test("right-to-left cylinders turn the mirrored way", arguments: [false, true])
    func mirrored(rtl: Bool) {
        var sut = makeSUT(rtl: rtl)
        sut.turn(to: 1)
        // Chamber 1 sits at `centerAngle`; turning by `rotationDegrees` puts it at 12 o'clock.
        let angle = sut.geometry.centerAngle(ofWedge: 1) + sut.rotationDegrees
        #expect(angle.truncatingRemainder(dividingBy: 360) == 0)
    }

    @Test("the firing hole is at 12 o'clock whatever the turn; other sectors aim their chamber")
    func targets() {
        var sut = makeSUT()
        let firing = WheelPoint(x: 0, y: sut.chamberRadius)
        #expect(sut.target(at: firing) == .firingHole)
        #expect(sut.target(at: WheelPoint(x: 0, y: -100)) == .chamber(3))
        #expect(sut.target(at: WheelPoint(x: 0, y: 0)) == .none)
        #expect(sut.target(at: WheelPoint(x: 0, y: -400)) == .none)
        sut.turn(to: 3)
        #expect(sut.target(at: firing) == .firingHole)
        // Stable aiming: the sector still names chamber 3, which is now in the firing position.
        #expect(sut.target(at: WheelPoint(x: 0, y: -100)) == .none)
        #expect(sut.target(at: WheelPoint(x: 86, y: 50)) == .chamber(1))
    }

    @Test("holes fit the ring depth and never overlap their neighbors", arguments: [1, 2, 7, 12])
    func holes(count: Int) {
        let sut = makeSUT(count: count)
        #expect(sut.holeRadius > 0)
        #expect(sut.holeRadius <= (sut.geometry.outerRadius - sut.geometry.innerRadius) / 2)
        if count > 1 {
            let spacing = 2 * sut.chamberRadius * sin(.pi / Double(count))
            #expect(sut.holeRadius * 2 < spacing)
        }
    }
}
