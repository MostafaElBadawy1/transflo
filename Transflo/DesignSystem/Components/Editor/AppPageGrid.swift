import SwiftUI

/// Page thumbnails in a grid; clicking one toggles it. Selected pages carry the accent ring.
struct AppPageGrid: View {
    @Environment(Localizer.self) private var localizer
    let thumbnails: [Data]
    let isSelected: (Int) -> Bool
    let onToggle: (Int) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: AppDimensions.Editor.pageThumbnailWidth),
                                         spacing: AppDimensions.Spacing.medium)],
                      spacing: AppDimensions.Spacing.medium) {
                ForEach(thumbnails.indices, id: \.self) { index in
                    Button { onToggle(index) } label: { cell(index) }
                        .buttonStyle(.plain)
                        .accessibilityLabel(localizer.string(.editorPage, arguments: [String(index + 1)]))
                        .accessibilityIdentifier("transflo.page.\(index + 1)")
                        .accessibilityAddTraits(isSelected(index) ? .isSelected : [])
                }
            }
            .padding(AppDimensions.Spacing.medium)
        }
        .frame(height: AppDimensions.Editor.listHeight)
        .appGlass(.card, in: RoundedRectangle(cornerRadius: AppDimensions.Radius.large))
    }

    private func cell(_ index: Int) -> some View {
        VStack(spacing: AppDimensions.Spacing.xSmall) {
            AppPreviewImage(data: thumbnails[index], backdrop: .clear)
                .frame(height: AppDimensions.Editor.pageThumbnailHeight)
                .opacity(isSelected(index) ? 1 : AppDimensions.Editor.unselectedOpacity)
                .overlay(RoundedRectangle(cornerRadius: AppDimensions.Radius.medium)
                    .strokeBorder(AppColors.accent, lineWidth: AppDimensions.Stroke.selection)
                    .opacity(isSelected(index) ? 1 : 0))
            AppText(verbatim: String(index + 1), style: .caption, color: isSelected(index) ? .primary : .secondary)
        }
    }
}
