import Foundation
import TransfloDomain

/// A two-pass video / bitrate audio compression Strategy with one bounded size retry.
struct MediaTargetCompressor {
    let ffmpeg: URL
    let ffprobe: URL?
    let naming: ToolOutputNaming

    func run(
        _ request: ToolRequest, target: Int64, progress: @escaping @Sendable (Double) -> Void
    ) async throws(JobError) -> [URL] {
        guard target > 0 else { throw .targetUnreachable }
        var outputs: [URL] = []
        do throws(JobError) {
            for (index, item) in request.items.enumerated() {
                if Task.isCancelled { throw .cancelled }
                let destination = try naming.destination(for: item.url, tool: .compress)
                try await compress(item, target: target, to: destination) { fraction in
                    progress((Double(index) + fraction) / Double(request.items.count))
                }
                outputs.append(destination)
            }
        } catch {
            throw outputs.isEmpty ? error : .partialFailure(completed: outputs, cause: error)
        }
        return outputs
    }

    private func compress(
        _ item: ToolItem, target: Int64, to destination: URL, progress: @escaping @Sendable (Double) -> Void
    ) async throws(JobError) {
        guard let size = try? item.url.resourceValues(forKeys: [.fileSizeKey]).fileSize else { throw .sourceMissing }
        let workspace = try TemporaryWorkspace(parent: destination.deletingLastPathComponent())
        defer { workspace.remove() }
        let format = item.format?.id.rawValue ?? ""
        guard FFmpegToolArguments.compressibleFormats.contains(format) else { throw .unsupported }
        guard let ffprobe else { throw .unsupported }
        let info = try await FFprobe.info(binary: ffprobe, file: item.url)
        if Int64(size) <= target {
            let copy = workspace.url.appendingPathComponent("original").appendingPathExtension(format)
            do { try FileManager.default.copyItem(at: item.url, to: copy) } catch { throw .destinationUnavailable }
            try ToolOutputPublisher.publish(copy, to: destination, isCancelled: { Task.isCancelled })
            return
        }
        for attempt in 0...1 {
            guard let plan = MediaTargetBitrate(targetBytes: target, duration: info.duration ?? 0,
                                               hasVideo: info.hasVideo, hasAudio: info.hasAudio,
                                               retry: attempt > 0) else { throw .targetUnreachable }
            let candidate = workspace.url.appendingPathComponent("candidate-\(attempt)").appendingPathExtension(format)
            try await encode(item, context: EncodingContext(format: format, plan: plan, attempt: attempt),
                             workspace: workspace.url,
                             candidate: candidate, progress: progress)
            if Task.isCancelled { throw .cancelled }
            guard let bytes = try? candidate.resourceValues(forKeys: [.fileSizeKey]).fileSize else { throw .failed }
            if Int64(bytes) <= target {
                try ToolOutputPublisher.publish(candidate, to: destination, isCancelled: { Task.isCancelled })
                return
            }
        }
        throw .targetUnreachable
    }

    private func encode(
        _ item: ToolItem,
        context: EncodingContext,
        workspace: URL,
        candidate: URL,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws(JobError) {
        let format = context.format
        let plan = context.plan
        let attempt = context.attempt
        let base = ["-i", item.url.path]
        var encoding = Self.encoding(format: format, plan: plan)
        if plan.video != nil {
            let passLog = workspace.appendingPathComponent("pass-\(attempt)").path
            let first = workspace.appendingPathComponent("first-\(attempt)").appendingPathExtension(format)
            let firstArgs = base + Self.videoEncoding(format: format, bitrate: plan.video ?? 0)
                + ["-an", "-pass", "1", "-passlogfile", passLog, first.path]
            try await FFmpegRunner.run(binary: ffmpeg, arguments: firstArgs, totalDuration: nil) { value in
                progress((Double(attempt) + value * 0.5) / 2)
            }
            encoding += ["-pass", "2", "-passlogfile", passLog]
        }
        try await FFmpegRunner.run(binary: ffmpeg, arguments: base + encoding + [candidate.path],
                                   totalDuration: nil) { value in
            progress((Double(attempt) + 0.5 + value * 0.5) / 2)
        }
    }

    private static func videoEncoding(format: String, bitrate: Int) -> [String] {
        // Native H.264 hardware encoding cannot share ffmpeg's software two-pass log.
        // MPEG-4 Part 2 and VP9 support two passes without introducing GPL codecs.
        ["-c:v", format == "webm" ? "libvpx-vp9" : "mpeg4", "-b:v", String(bitrate),
         "-pix_fmt", "yuv420p", "-vf", "scale=trunc(iw/2)*2:trunc(ih/2)*2"]
    }

    private static func encoding(format: String, plan: MediaTargetBitrate) -> [String] {
        var arguments = plan.video.map { videoEncoding(format: format, bitrate: $0) } ?? ["-vn"]
        if let audio = plan.audio {
            let codecs = ["mp3": "libmp3lame", "m4a": "aac", "ogg": "libvorbis", "opus": "libopus",
                          "wma": "wmav2", "webm": "libopus"]
            arguments += ["-c:a", codecs[format] ?? "aac", "-b:a", String(min(audio, 320_000))]
        } else {
            arguments += ["-an"]
        }
        if format == "mp4" { arguments += ["-movflags", "+faststart"] }
        return arguments
    }
    private struct EncodingContext {
        let format: String
        let plan: MediaTargetBitrate
        let attempt: Int
    }
}
