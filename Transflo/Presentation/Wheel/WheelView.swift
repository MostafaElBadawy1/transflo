import SwiftUI

/// The open wheel, composed from the view model's state.
struct WheelView: View {
    let viewModel: WheelViewModel

    var body: some View {
        if let kind = viewModel.state.kind {
            AppRadialWheel(
                wedges: viewModel.state.slots.map(WheelPresentation.wedge(for:)),
                geometry: viewModel.state.geometry,
                highlightedIndex: viewModel.state.highlightedIndex,
                hubTitle: viewModel.hubTitle,
                hubGlyph: viewModel.hubGlyph,
                hubDetail: viewModel.hubDetail,
                itemCount: viewModel.state.summary?.itemCount ?? 1
            )
            .id("\(kind)-\(viewModel.state.page)")
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
    }
}
