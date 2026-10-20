import SwiftUI

/// The open wheel, composed from the view model's state: the radial wheel, or in Russian Roulette
/// mode the revolver cylinder.
struct WheelView: View {
    let viewModel: WheelViewModel

    var body: some View {
        if let kind = viewModel.state.kind, let cylinder = viewModel.state.cylinder {
            AppRevolverCylinder(
                wedges: viewModel.state.slots.map(WheelPresentation.wedge(for:)),
                cylinder: cylinder,
                hubTitle: viewModel.hubTitle,
                hubGlyph: viewModel.hubGlyph,
                hubDetail: viewModel.hubDetail,
                itemCount: viewModel.state.summary?.itemCount ?? 1,
                shot: viewModel.state.shot
            )
            .id("\(kind)-\(viewModel.state.group?.rawValue ?? "root")-\(viewModel.state.page)")
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        } else if let kind = viewModel.state.kind {
            AppRadialWheel(
                wedges: viewModel.state.slots.map(WheelPresentation.wedge(for:)),
                geometry: viewModel.state.geometry,
                highlightedIndex: viewModel.state.highlightedIndex,
                hubTitle: viewModel.hubTitle,
                hubGlyph: viewModel.hubGlyph,
                hubDetail: viewModel.hubDetail,
                itemCount: viewModel.state.summary?.itemCount ?? 1
            )
            .id("\(kind)-\(viewModel.state.group?.rawValue ?? "root")-\(viewModel.state.page)")
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
    }
}
