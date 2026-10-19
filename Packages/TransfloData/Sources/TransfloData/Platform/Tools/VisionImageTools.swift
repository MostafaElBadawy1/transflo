import CoreGraphics
import CoreImage
import PDFKit
import TransfloDomain
import Vision

/// Vision-backed image tools: background removal and barcode reading.
enum VisionImageTools {
    /// The image with everything but its foreground subjects made transparent.
    static func removeBackground(from image: CGImage) throws(JobError) -> CGImage {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: image)
        do {
            try handler.perform([request])
        } catch {
            throw .failed
        }
        guard let observation = request.results?.first, !observation.allInstances.isEmpty else { throw .nothingFound }
        guard let masked = try? observation.generateMaskedImage(
            ofInstances: observation.allInstances, from: handler, croppedToInstancesExtent: false
        ) else { throw .failed }
        let ciImage = CIImage(cvPixelBuffer: masked)
        guard let result = CIContext().createCGImage(ciImage, from: ciImage.extent) else { throw .failed }
        return result
    }

    /// Every distinct barcode / QR payload in `images`, in reading order.
    static func codes(in images: [CGImage]) -> [String] {
        var found: [String] = []
        for image in images {
            let request = VNDetectBarcodesRequest()
            try? VNImageRequestHandler(cgImage: image).perform([request])
            let payloads = (request.results ?? [])
                .sorted { $0.boundingBox.minY > $1.boundingBox.minY }
                .compactMap(\.payloadStringValue)
            for payload in payloads where !found.contains(payload) {
                found.append(payload)
            }
        }
        return found
    }

    /// Detects one PDF page at a time, releasing its raster before rendering the next.
    static func codes(inPDF url: URL, isCancelled: () -> Bool) throws(JobError) -> [String] {
        let document = try PDFKitEngine.open(url)
        var found: [String] = []
        for index in 0..<document.pageCount {
            if isCancelled() { throw .cancelled }
            let payloads = try RasterLimits.withPool { () throws(JobError) -> [String] in
                guard let page = document.page(at: index) else { return [] }
                return codes(in: [try PDFPageImageExporter.render(page, dpi: 200)])
            }
            for payload in payloads where !found.contains(payload) { found.append(payload) }
        }
        return found
    }
}
