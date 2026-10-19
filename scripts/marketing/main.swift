import AppKit

// Renders Transflo's marketing video from the README screenshots.
//   promo render <repo-root> <out.mp4>
//   promo still <repo-root> <out.png> <seconds>
let size = CGSize(width: 1920, height: 1080)
let framesPerSecond: Int32 = 30
let arguments = CommandLine.arguments

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("error: \(message)\n".utf8))
    exit(1)
}

guard arguments.count >= 4, ["render", "still"].contains(arguments[1]) else {
    fail("usage: promo render <repo-root> <out.mp4> | promo still <repo-root> <out.png> <seconds>")
}
let root = URL(fileURLWithPath: arguments[2])
let output = URL(fileURLWithPath: arguments[3])
do {
    let timeline = try PromoStoryboard.timeline(
        assets: PromoAssets(folder: root.appendingPathComponent("docs/screenshots"))
    )
    if arguments[1] == "still" {
        guard arguments.count == 5, let seconds = Double(arguments[4]) else { fail("still needs <seconds>") }
        try PromoStillWriter(size: size).write(to: output) { context in
            PromoCanvas.render(on: context, size: size) { timeline.draw(on: $0, at: seconds) }
        }
    } else {
        let frameCount = Int((timeline.duration * Double(framesPerSecond)).rounded())
        let encoder = PromoEncoder(size: size, framesPerSecond: framesPerSecond, bitrate: 3_500_000)
        try encoder.encode(frameCount: frameCount, to: output) { context, index in
            PromoCanvas.render(on: context, size: size) {
                timeline.draw(on: $0, at: Double(index) / Double(framesPerSecond))
            }
        }
        print(String(format: "Wrote %@ (%.1f s, %d frames)", output.path, timeline.duration, frameCount))
    }
} catch {
    fail(String(describing: error))
}
