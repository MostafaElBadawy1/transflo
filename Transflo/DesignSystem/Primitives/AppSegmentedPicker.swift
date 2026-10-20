import AppKit
import SwiftUI

/// Native, localized segments with explicit widths so a selection cannot change their layout.
struct AppSegmentedPicker<Value: Hashable>: View {
    struct Option: Identifiable {
        let value: Value
        let label: L10nKey
        var id: Value { value }
    }

    @Environment(Localizer.self) private var localizer
    @Environment(\.layoutDirection) private var direction
    @Environment(\.isEnabled) private var isEnabled
    let key: L10nKey
    @Binding var selection: Value
    let options: [Option]
    var width: CGFloat?

    var body: some View {
        NativeControl(label: localizer.string(key), selection: $selection, isEnabled: isEnabled,
                      options: direction == .rightToLeft ? options.reversed() : options,
                      labels: (direction == .rightToLeft ? options.reversed() : options).map {
                          localizer.string($0.label)
                      }, width: width)
            .fixedSize()
    }

    private struct NativeControl: NSViewRepresentable {
        let label: String
        @Binding var selection: Value
        let isEnabled: Bool
        let options: [Option]
        let labels: [String]
        let width: CGFloat?

        func makeCoordinator() -> Coordinator { Coordinator(self) }

        func makeNSView(context: Context) -> NSSegmentedControl {
            let control = NSSegmentedControl()
            control.trackingMode = .selectOne
            control.segmentStyle = .rounded
            control.target = context.coordinator
            control.action = #selector(Coordinator.changed(_:))
            return control
        }

        func updateNSView(_ control: NSSegmentedControl, context: Context) {
            context.coordinator.parent = self
            control.isEnabled = isEnabled
            if control.segmentCount != labels.count { control.segmentCount = labels.count }
            control.setAccessibilityLabel(label)
            control.selectedSegmentBezelColor = NSColor(AppColors.accent)
            for (index, title) in labels.enumerated() {
                if control.label(forSegment: index) != title { control.setLabel(title, forSegment: index) }
                let width = segmentWidth(title)
                if control.width(forSegment: index) != width { control.setWidth(width, forSegment: index) }
            }
            let selected = options.firstIndex { $0.value == selection } ?? -1
            if control.selectedSegment != selected { control.selectedSegment = selected }
        }

        func sizeThatFits(
            _ proposal: ProposedViewSize,
            nsView: NSSegmentedControl,
            context: Context
        ) -> CGSize? {
            CGSize(width: labels.reduce(CGFloat.zero) { $0 + segmentWidth($1) },
                   height: nsView.intrinsicContentSize.height)
        }

        private func segmentWidth(_ title: String) -> CGFloat {
            if let width { return width / CGFloat(max(1, labels.count)) }
            let font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
            return ceil((title as NSString).size(withAttributes: [.font: font]).width)
                + AppDimensions.Spacing.large * 2
        }
    }

    private final class Coordinator: NSObject {
        var parent: NativeControl
        init(_ parent: NativeControl) { self.parent = parent }

        @objc func changed(_ control: NSSegmentedControl) {
            guard parent.options.indices.contains(control.selectedSegment) else { return }
            parent.selection = parent.options[control.selectedSegment].value
        }
    }
}
