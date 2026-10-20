import TransfloDomain

extension WheelViewModel {
    /// Everything the wheel renders.
    struct State: Equatable {
        var kind: WheelKind?
        var options: [WheelOption] = []
        var summary: DragSummary?
        var page = 0
        var group: WheelToolGroup?
        var slots: [WheelSlot] = []
        var highlightedIndex: Int?
        var geometry = WheelGeometry(wedgeCount: 0, innerRadius: 0, outerRadius: 0, isRightToLeft: false)
        /// Russian Roulette mode only. The highlight is then the chamber in the firing position.
        var cylinder: CylinderAim?
        /// The trigger was pulled; the wheel is closing.
        var shot: RouletteOutcome?
    }
}

/// Russian Roulette mode.
extension WheelViewModel.State {
    /// The slot a click or drop at `offset` lands on: the wedge under it, or with a cylinder the
    /// chamber in the firing position when `offset` is on its hole (nothing anywhere else).
    func slotIndex(at offset: WheelPoint) -> Int? {
        guard let cylinder else { return geometry.wedgeIndex(at: offset) }
        guard shot == nil, cylinder.target(at: offset) == .firingHole else { return nil }
        return highlightedIndex
    }

    /// What the pointer is over; `.none` without a cylinder, off the wheel, or once fired.
    func cylinderTarget(at offset: WheelPoint?) -> CylinderAim.Target {
        guard shot == nil, let cylinder, let offset else { return .none }
        return cylinder.target(at: offset)
    }

    /// Whether the firing position holds something a drop can use (an option, a group or Back;
    /// More only turns pages on a dwell, as on the plain wheel).
    var canFire: Bool {
        guard shot == nil, let index = highlightedIndex, slots.indices.contains(index) else { return false }
        return slots[index] != .more
    }

    /// A fresh cylinder for the current slots, first chamber in the firing position; or none.
    mutating func loadCylinder(isEnabled: Bool) {
        cylinder = isEnabled ? CylinderAim(geometry: geometry) : nil
        if cylinder != nil { highlightedIndex = 0 }
    }

    /// Turns chamber `index` into the firing position and highlights it.
    /// - Returns: Signed chamber steps turned; 0 without a cylinder, once fired, or if already there.
    mutating func turnCylinder(to index: Int) -> Int {
        guard shot == nil, var aim = cylinder, slots.indices.contains(index) else { return 0 }
        let steps = aim.turn(to: index)
        cylinder = aim
        highlightedIndex = index
        return steps
    }
}
