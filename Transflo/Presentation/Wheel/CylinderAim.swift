import Foundation
import TransfloDomain

/// Russian Roulette mode: the wheel's options as chambers of a revolver cylinder that turns so the
/// aimed chamber sits in the firing position at 12 o'clock.
///
/// Aiming is stable: the pointer's angle picks a chamber from the layout as it was before any
/// turn (the same sectors `WheelGeometry` hit-tests), so turning the cylinder never changes what
/// is under the pointer. Only the hole in the firing position takes a drop. Layout and hit-testing
/// share these numbers, so the drawn firing hole and the drop target always agree.
nonisolated struct CylinderAim: Equatable {
    /// What the pointer is over.
    enum Target: Equatable {
        /// The hole in the firing position: drops land here.
        case firingHole
        /// Another chamber's sector, which turns that chamber into the firing position.
        case chamber(Int)
        /// The center, outside the cylinder, or the chamber already in the firing position.
        case none
    }

    /// Hole size as a share of the room a chamber has (ring depth, or the gap to its neighbors).
    static let holeFill = 0.8
    /// Extra reach around the firing hole, so a drop on its rim still counts.
    static let firingTolerance = 1.2

    let geometry: WheelGeometry
    /// Chamber steps turned since the wheel opened, signed, so the cylinder always animates the
    /// short way round. Positive turns run in reading order (clockwise left to right).
    private(set) var turns = 0

    init(geometry: WheelGeometry) {
        self.geometry = geometry
    }

    /// The chamber in the firing position.
    var selectedIndex: Int {
        let count = max(geometry.wedgeCount, 1)
        return (turns % count + count) % count
    }

    /// How far the whole cylinder is turned, in degrees clockwise.
    var rotationDegrees: Double {
        Double(turns) * geometry.wedgeSpan * (geometry.isRightToLeft ? 1 : -1)
    }

    /// Distance from the center to each chamber's middle.
    var chamberRadius: Double { (geometry.innerRadius + geometry.outerRadius) / 2 }

    var holeRadius: Double {
        let depth = (geometry.outerRadius - geometry.innerRadius) / 2
        guard geometry.wedgeCount > 1 else { return depth * Self.holeFill }
        let neighborRoom = chamberRadius * sin(.pi / Double(geometry.wedgeCount))
        return min(depth, neighborRoom) * Self.holeFill
    }

    func target(at offset: WheelPoint) -> Target {
        if hypot(offset.x, offset.y - chamberRadius) <= holeRadius * Self.firingTolerance { return .firingHole }
        guard let index = geometry.wedgeIndex(at: offset), index != selectedIndex else { return .none }
        return .chamber(index)
    }

    /// Turns `index` into the firing position the short way round.
    /// - Returns: Signed chamber steps turned (0 if it was already there).
    @discardableResult
    mutating func turn(to index: Int) -> Int {
        let steps = Self.shortestSteps(from: selectedIndex, to: index, count: geometry.wedgeCount)
        turns += steps
        return steps
    }

    /// Signed steps from chamber `from` to `to` on a ring of `count`; a half turn goes forward.
    static func shortestSteps(from: Int, to: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        let forward = ((to - from) % count + count) % count
        return forward > count / 2 ? forward - count : forward
    }
}
