import SwiftUI

/// Crop editor: the crop box over the preview and shape presets.
struct CropEditorView: View {
    let model: CropEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppPreviewImage(data: model.preview.thumbnail)
                .overlay {
                    if model.preview.thumbnail != nil {
                        AppCropOverlay(rect: model.rect) { proposal, _ in model.propose(proposal) }
                    }
                }
                .modifier(AppPreviewFrame(aspectRatio: PreviewAspect.ratio(model.preview)))
            AppChipGroup(key: .editorAspect, selection: aspectBinding, options: Self.aspects)
            HStack(spacing: AppDimensions.Spacing.large) {
                AppNumberField(label: .editorWidth,
                               value: Binding(get: { model.pixelWidth }, set: { model.setWidth($0) }),
                               range: 1...model.maximumWidth, unit: .unitPixels, rejectsBelowMinimum: true)
                AppNumberField(label: .editorHeight,
                               value: Binding(get: { model.pixelHeight }, set: { model.setHeight($0) }),
                               range: 1...model.maximumHeight, unit: .unitPixels, rejectsBelowMinimum: true)
            }
            AppButton(key: .editorReset, variant: .tertiary) { model.reset() }
        }
    }

    private var aspectBinding: Binding<CropAspect> {
        Binding(get: { model.aspect }, set: { model.select($0) })
    }

    private static let aspects: [AppSegmentedPicker<CropAspect>.Option] = [
        .init(value: .free, label: .aspectFree), .init(value: .original, label: .aspectOriginal),
        .init(value: .square, label: .aspectSquare), .init(value: .fourThree, label: .aspectFourThree),
        .init(value: .sixteenNine, label: .aspectSixteenNine),
        .init(value: .nineSixteen, label: .aspectNineSixteen),
        .init(value: .threeFour, label: .aspectThreeFour), .init(value: .fourFive, label: .aspectFourFive)
    ]
}
