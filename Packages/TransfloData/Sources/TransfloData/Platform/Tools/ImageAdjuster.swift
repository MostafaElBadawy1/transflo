import CoreGraphics
import CoreImage
import TransfloDomain

/// Applies `ImageAdjustments` with Core Image (exposure, then contrast and saturation).
/// Shared by the Adjust tool and its live editor preview, so both look identical.
enum ImageAdjuster {
    static func apply(_ adjustments: ImageAdjustments, to image: CGImage) throws(JobError) -> CGImage {
        guard !adjustments.isNeutral else { return image }
        var output = CIImage(cgImage: image)
        if adjustments.exposure != 0, let exposure = CIFilter(name: "CIExposureAdjust") {
            exposure.setValue(output, forKey: kCIInputImageKey)
            exposure.setValue(adjustments.exposure, forKey: kCIInputEVKey)
            output = exposure.outputImage ?? output
        }
        if let colors = CIFilter(name: "CIColorControls") {
            colors.setValue(output, forKey: kCIInputImageKey)
            colors.setValue(adjustments.contrast, forKey: kCIInputContrastKey)
            colors.setValue(adjustments.saturation, forKey: kCIInputSaturationKey)
            output = colors.outputImage ?? output
        }
        let extent = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        guard let result = CIContext().createCGImage(output.cropped(to: extent), from: extent) else { throw .failed }
        return result
    }
}
