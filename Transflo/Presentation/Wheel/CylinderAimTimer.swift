/// Aims the cylinder only once the pointer rests on a chamber, so crossing chambers on the way to
/// the firing hole doesn't turn it. Moving on to another chamber restarts the wait; staying on the
/// same one keeps it.
final class CylinderAimTimer {
    private var pending: (index: Int, task: Task<Void, Never>)?

    /// Calls `aim` with `index` after `delay` (at once for zero), unless cancelled or replaced.
    func schedule(_ index: Int, after delay: Duration, aim: @escaping @MainActor (Int) -> Void) {
        guard pending?.index != index else { return }
        cancel()
        guard delay > .zero else { return aim(index) }
        let task = Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            self?.pending = nil
            aim(index)
        }
        pending = (index, task)
    }

    func cancel() {
        pending?.task.cancel()
        pending = nil
    }
}
