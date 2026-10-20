import AppKit

// Renders Transflo's marketing video from the README screenshots.
//   promo render <repo-root> <out.mp4>
//   promo still <repo-root> <out.png> <seconds>
//   promo appstore <repo-root> <out-folder>
//   promo customization <repo-root> <out-folder>   (landscape/ and square/ PNGs)
//   promo readme <repo-root> <out-folder>          (designed feature panels)
let size = CGSize(width: 1920, height: 1080)
let framesPerSecond: Int32 = 30
let arguments = CommandLine.arguments

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("error: \(message)\n".utf8))
    exit(1)
}

guard arguments.count >= 4, ["render", "still", "appstore", "customization", "readme"].contains(arguments[1]) else {
    fail("usage: promo render <repo-root> <out.mp4> | promo still <repo-root> <out.png> <seconds>"
        + " | promo appstore|customization|readme <repo-root> <out-folder>")
}
let root = URL(fileURLWithPath: arguments[2])
let output = URL(fileURLWithPath: arguments[3])
/// Renders `screens` as PNGs named `<prefix>-<screen>.png` into `folder`.
func renderStills(
    _ screens: [MarketingFrame.Screen],
    size: CGSize,
    assets: PromoAssets,
    prefix: String,
    into folder: URL
) throws {
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    for screen in screens {
        let file = folder.appendingPathComponent("\(prefix)-\(screen.name).png")
        var failure: Error?
        try PromoStillWriter(size: size).write(to: file) { context in
            PromoCanvas.render(on: context, size: size) {
                do { try MarketingFrame.draw(screen, on: $0, size: size, assets: assets) } catch { failure = error }
            }
        }
        if let failure { throw failure }
        print("Wrote \(file.path)")
    }
}

if ["appstore", "customization", "readme"].contains(arguments[1]) {
    do {
        if arguments[1] == "readme" {
            try renderStills(ReadmeScreens.screens, size: MarketingFrame.landscape,
                             assets: PromoAssets(folder: root.appendingPathComponent("docs/screenshots")),
                             prefix: "feature", into: output)
        } else if arguments[1] == "appstore" {
            try renderStills(AppStoreScreens.screens, size: MarketingFrame.landscape,
                             assets: PromoAssets(folder: root.appendingPathComponent("docs/screenshots")),
                             prefix: "appstore", into: output)
        } else {
            let captures = PromoAssets(folder: root.appendingPathComponent("build/marketing/captures"))
            for (size, format) in [(MarketingFrame.landscape, "landscape"), (MarketingFrame.square, "square")] {
                try renderStills(CustomizationScreens.screens, size: size, assets: captures, prefix: "customize",
                                 into: output.appendingPathComponent(format))
            }
        }
    } catch {
        fail(String(describing: error))
    }
    exit(0)
}
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
