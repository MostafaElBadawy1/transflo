import SwiftUI
import TransfloDomain

struct CompressEditorView: View {
    @Environment(Localizer.self) private var localizer
    @Bindable var model: CompressEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.Spacing.large) {
            if let name = model.fileName {
                AppText(verbatim: name, style: .caption, color: .secondary).lineLimit(2)
            } else {
                AppText(.jobFileCount, arguments: [String(model.itemCount)], color: .secondary)
            }
            if let bytes = model.originalBytes {
                sizeRow(.compressionOriginalSize, bytes: bytes)
            }
            if model.supportsBudget {
                AppChipGroup(key: .compressionMode, selection: $model.mode, options: [
                    .init(value: .preset, label: .compressionPreset),
                    .init(value: .fileSize, label: .compressionTarget),
                    .init(value: .percentage, label: .compressionPercentage)
                ])
            }
            if model.supportsBudget { controls }
            if let target = model.estimatedTargetBytes { sizeRow(.compressionTargetTotal, bytes: target) }
            if model.isImage {
                AppText(.compressionImageSize, style: .caption, color: .secondary)
                AppChipGroup(key: .compressionImageSize, selection: $model.imageSize, options: [
                    .init(value: .original, label: .compressionOriginalDimensions),
                    .init(value: .small, label: .compressionSize1280),
                    .init(value: .medium, label: .compressionSize1920),
                    .init(value: .large, label: .compressionSize2560),
                    .init(value: .custom, label: .editorCustomSize)
                ])
            }
            if model.isImage && model.imageSize == .custom {
                AppNumberField(label: .compressionImageSize, value: $model.customLongEdge,
                               range: 1...16_384, unit: .unitPixels)
            }
            SettingsFootnote(message: hint)
        }
    }

    @ViewBuilder private var controls: some View {
        switch model.mode {
        case .preset:
            AppChipGroup(key: .compressionPreset, selection: $model.level, options: [
                .init(value: .light, label: .compressionLight), .init(value: .medium, label: .compressionMedium),
                .init(value: .strong, label: .compressionStrong)
            ])
        case .fileSize:
            AppDecimalNumberField(label: .compressionTargetPerFile, unit: .unitMegabytes, value: $model.megabytes)
        case .percentage:
            AppNumberField(label: .compressionKeepPercentage, value: $model.percentage,
                           range: 1...99, unit: .unitPercent)
        }
    }

    private var hint: L10nKey {
        if !model.supportsBudget { return .compressionPDFHint }
        if model.mode == .preset { return .compressionPresetHint }
        return model.mode == .percentage ? .compressionPercentageHint : .compressionEditorHint
    }

    private func sizeRow(_ label: L10nKey, bytes: Int64) -> some View {
        HStack {
            AppText(label, color: .secondary)
            Spacer()
            AppText(verbatim: FileByteSizeFormatter().string(bytes: bytes, locale: localizer.locale))
                .monospacedDigit()
        }
    }
}
