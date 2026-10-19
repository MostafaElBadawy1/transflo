import SwiftUI
import TransfloDomain

/// Adjust editor: live preview and exposure / contrast / saturation sliders.
struct AdjustEditorView: View {
    @Bindable var model: AdjustEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.medium) {
            AppPreviewImage(data: model.adjustedThumbnail).frame(height: AppDimensions.Editor.previewHeight)
            AppSlider(label: .editorExposure, value: $model.exposure, range: ImageAdjustments.exposureRange,
                      valueText: Self.signed(model.exposure))
            AppSlider(label: .editorContrast, value: $model.contrast, range: ImageAdjustments.contrastRange,
                      valueText: Self.percent(model.contrast))
            AppSlider(label: .editorSaturation, value: $model.saturation, range: ImageAdjustments.saturationRange,
                      valueText: Self.percent(model.saturation))
            AppButton(key: .editorReset, variant: .tertiary) { model.reset() }
        }
        .task(id: model.adjustments) {
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }
            await model.refreshPreview()
        }
    }

    private static func signed(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)).sign(strategy: .always(includingZero: false)))
    }

    private static func percent(_ value: Double) -> String {
        value.formatted(.percent.precision(.fractionLength(0)))
    }
}
