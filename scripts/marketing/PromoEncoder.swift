import AVFoundation
import CoreVideo

/// Adapter over AVAssetWriter: draws each frame through a closure and encodes H.264 into an MP4.
struct PromoEncoder {
    enum EncoderError: Error, CustomStringConvertible {
        case setup(String)
        case frame(Int)

        var description: String {
            switch self {
            case .setup(let reason): "encoder setup failed: \(reason)"
            case .frame(let index): "could not encode frame \(index)"
            }
        }
    }

    let size: CGSize
    let framesPerSecond: Int32
    let bitrate: Int

    func encode(frameCount: Int, to output: URL, draw: (CGContext, Int) -> Void) throws {
        let writer = try AVAssetWriter(outputURL: output, fileType: .mp4)
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        input.expectsMediaDataInRealTime = false
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: Int(size.width),
            kCVPixelBufferHeightKey as String: Int(size.height)
        ])
        guard writer.canAdd(input) else { throw EncoderError.setup("cannot add the video input") }
        writer.add(input)
        guard writer.startWriting() else {
            throw EncoderError.setup(writer.error?.localizedDescription ?? "cannot start writing")
        }
        writer.startSession(atSourceTime: .zero)
        for index in 0..<frameCount {
            while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.002) }
            let buffer = try makeFrame(index, pool: adaptor.pixelBufferPool, draw: draw)
            let time = CMTime(value: CMTimeValue(index), timescale: framesPerSecond)
            guard adaptor.append(buffer, withPresentationTime: time) else { throw EncoderError.frame(index) }
        }
        input.markAsFinished()
        let finished = DispatchSemaphore(value: 0)
        writer.finishWriting { finished.signal() }
        finished.wait()
        guard writer.status == .completed else {
            throw EncoderError.setup(writer.error?.localizedDescription ?? "the file was not finished")
        }
    }

    private var outputSettings: [String: Any] {
        [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(size.width),
            AVVideoHeightKey: Int(size.height),
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: bitrate,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                AVVideoMaxKeyFrameIntervalKey: Int(framesPerSecond) * 2
            ],
            AVVideoColorPropertiesKey: [
                AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
                AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2
            ]
        ]
    }

    private func makeFrame(
        _ index: Int,
        pool: CVPixelBufferPool?,
        draw: (CGContext, Int) -> Void
    ) throws -> CVPixelBuffer {
        var created: CVPixelBuffer?
        guard let pool, CVPixelBufferPoolCreatePixelBuffer(nil, pool, &created) == kCVReturnSuccess,
              let buffer = created else { throw EncoderError.frame(index) }
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: CVPixelBufferGetBaseAddress(buffer),
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
              ) else { throw EncoderError.frame(index) }
        draw(context, index)
        return buffer
    }
}
