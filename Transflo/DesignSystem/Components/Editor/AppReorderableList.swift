import SwiftUI

/// A vertical list the user reorders by dragging rows. Items must be unique.
struct AppReorderableList<Item: Hashable, Row: View>: View {
    let items: [Item]
    let onMove: (IndexSet, Int) -> Void
    @ViewBuilder let row: (Item) -> Row

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in row(item) }
                .onMove(perform: onMove)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.vertical, AppDimensions.Spacing.xSmall)
        .frame(height: AppDimensions.Editor.listHeight)
        .appGlass(.card, in: RoundedRectangle(cornerRadius: AppDimensions.Radius.large))
    }
}
