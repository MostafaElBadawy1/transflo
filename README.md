<p align="center">
  <img src="docs/screenshots/icon.png" width="128" height="128" alt="Transflo app icon">
</p>

<h1 align="center">Transflo</h1>

<p align="center">
  <strong>Your files, transformed at your cursor.</strong><br>
  Drag a file, tap a key, drop it on the wheel: convert, edit or send it without opening another app.<br>
  Free and open source for macOS. File processing runs on your Mac.<br>
  <a href="https://transflo.ali-fayed.com">transflo.ali-fayed.com</a>
</p>

<p align="center">
  <a href="https://github.com/Ali-Fayed/transflo/releases/latest"><img alt="Download" src="https://img.shields.io/github/v/release/Ali-Fayed/transflo?label=download&color=1f6f63"></a>
  <img alt="macOS 14+" src="https://img.shields.io/badge/macOS-14%2B-1f6f63">
  <img alt="Apple silicon" src="https://img.shields.io/badge/Apple%20silicon-native-1f6f63">
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-1f6f63"></a>
</p>

<p align="center">
  <img src="docs/media/transflo-demo.webp" width="720" alt="Transflo demo: drag a photo, tap Shift and drop it on JPG; the wheel folds into a disc that fills and ticks; then the three wheels, Settings › Wheel, the editors, compression, English and Arabic, and customization"><br>
  <sub>Want it sharper? <a href="https://github.com/Ali-Fayed/transflo/raw/main/docs/media/transflo-promo.mp4">Download the 1080p video</a> (16 MB).</sub>
</p>

## Transflo Wheel

<p align="center">
  <img src="docs/screenshots/wheel-convert-en-light.png" width="420" alt="The Convert wheel">
  <img src="docs/screenshots/wheel-convert-en-dark.png" width="420" alt="The Convert wheel in dark mode">
</p>

---

## How it works

1. **Start dragging** any file (or a few) in Finder.
2. **Tap a key** while you drag. A wheel opens right under your pointer:
   - **⇧ Shift:** Convert
   - **⌘ Command:** Tools
   - **⌃ Control:** Actions
3. **Drop on a petal.** Conversions and edits create a new result beside the original. The wheel folds into a small disc that fills as the job runs, then ticks when it's done (or shakes with the reason if it fails); click it to reveal the file. Rename and Move apply the requested change to the selected files.

The wheel stays open after you let go of the key, so take your time. Tap another key to switch wheels. Only options that work for **every** file you're dragging are shown.

> Prefer the keyboard? Select files in Finder and press **⌥⌘Return**. Use the arrows to pick, **Return** to apply and **Esc** to cancel. Or right-click and choose **Quick Actions › Open in Transflo**.

## What it can do

### ⇧ Convert: 262 conversions
| Family | Formats |
|---|---|
| Images | JPG · PNG · HEIC · WebP · AVIF · TIFF · BMP · GIF · SVG (in) → PDF |
| Audio | MP3 · M4A · WAV · FLAC · OGG · Opus · AIFF · WMA |
| Video | MP4 · MOV · MKV · WebM · AVI · WMV · animated GIF, plus audio extraction to MP3 |
| Documents | PDF ↔ DOCX · Pages · Markdown · TXT · EPUB · HTML · RTF / RTFD · text clippings |
| PDF | → DOCX · Pages · PPTX · XLSX · EPUB · Markdown · TXT · JPG / PNG (every page) |
| Spreadsheets | XLSX · ODS · CSV · TSV (XLS in) → PDF |
| Slides | PPTX / PPT → PDF · JPG · PNG |
| Subtitles | SRT ↔ VTT → TXT |
| Archives | ZIP · TAR · GZIP (RAR in) |

### ⌘ Tools: 26 of them
<p align="center">
  <img src="docs/screenshots/editor-annotate-light.png" width="300" alt="Annotate editor">
  <img src="docs/screenshots/editor-crop-dark.png" width="300" alt="Crop editor">
  <img src="docs/screenshots/editor-reorganizePages-light.png" width="300" alt="Reorganize PDF pages">
</p>

| | |
|---|---|
| **Images** | Compress · Resize · Crop · Rotate & flip · Adjust (exposure, contrast, saturation) · Annotate (boxes, arrows, pen, text) · Redact · Remove background · Add background · Read QR / barcode · Images → PDF · Collage |
| **Video & audio** | Compress · Resize · Crop · Trim · Change speed · Split · Merge · Snapshot a frame · Mute · Normalize loudness · Bleep · Stereo → mono |
| **PDF** | Compress · Rotate · Split · Merge · Reorganize pages · Extract pages · Annotate · Redact (the covered text is really gone) · Read QR |
| **Metadata & names** | Edit metadata (title, author, comment) · Remove metadata (images, audio, video, PDF) · Rename any files with a pattern (`{name}`, `{n}`) |

Tools that need a choice open a focused editor first; the rest start directly. Crop offers aspect ratios and exact pixel dimensions. Add Background offers canvas ratios, solid colors, gradients, padding, corners and shadows. Compression can use a quality preset or aim for a size limit; some content cannot reach a very small limit.

<p align="center">
  <img src="docs/screenshots/editor-addBackground-light.png" width="420" alt="Add Background editor in light mode">
  <img src="docs/screenshots/editor-addBackground-dark.png" width="420" alt="Add Background editor in dark mode">
</p>

### ⌃ Actions
<p align="center">
  <img src="docs/screenshots/wheel-actions-en-light.png" width="300" alt="The Actions wheel">
  <img src="docs/screenshots/shelf.png" width="300" alt="The Float shelf">
</p>

**AirDrop** · **Float**: park files on a floating shelf and drag them out later · **Copy** (paste the files anywhere) · **Move**: to one of your recent folders or a new one · **Copy Path** (hold ⌥ for `~/…`) · **Terminal**: open the folder in Terminal, iTerm, Ghostty or Warp.

## Made to feel at home on your Mac
<p align="center">
  <img src="docs/screenshots/settings-customization-light.png" width="420" alt="Customization settings in light mode">
  <img src="docs/screenshots/settings-customization-dark.png" width="420" alt="Customization settings in dark mode">
</p>

- **Liquid Glass** on macOS 26, a frosted look on macOS 14–15, or solid surfaces if you prefer.
- **Make it yours:** choose an accent color and wheel size, pick which key opens which wheel, and set your own global shortcut. Preferences are saved across launches.
- **Only what you use:** in Settings › Wheel, untick any format, tool or action you never need. Keep five or six per wheel and every petal gets bigger and easier to hit.
<p align="center">
  <img src="docs/screenshots/settings-wheel-light.png" width="420" alt="Settings › Wheel: tick the formats, tools and actions each wheel shows">
</p>

- **Output preferences:** choose a compression preset or size limit, and how edited files are named. Short Settings tabs fit their content; longer tabs scroll.
- **Getting Started:** a five-page tour introduces the menu bar, wheels, tools and shortcuts. Replay it from the menu bar.
- **Check for Updates…:** request the latest stable GitHub release from the menu bar, then open its download page.
- **Jobs window** (⌘J) to follow, cancel or reveal everything you've run. Long jobs send a notification.
- **English and العربية**, with full right-to-left layout, light and dark.
- **VoiceOver:** petals are buttons with hints, and finished jobs are announced. Reduce Motion is respected.

<p align="center">
  <img src="docs/screenshots/settings-output-light.png" width="420" alt="Compression and naming preferences in light mode">
  <img src="docs/screenshots/settings-output-dark.png" width="420" alt="Compression and naming preferences in dark mode">
</p>

<details>
<summary>Getting Started, Jobs and Arabic</summary>
<p align="center">
  <img src="docs/screenshots/welcome-light.png" width="420" alt="Getting Started in light mode">
  <img src="docs/screenshots/welcome-dark.png" width="420" alt="Getting Started in dark mode">
  <img src="docs/screenshots/jobs.png" width="420" alt="Job progress and results">
  <img src="docs/screenshots/wheel-actions-ar-dark.png" width="420" alt="Actions wheel in Arabic with right-to-left layout">
</p>
</details>

## Private by design
Transflo does not upload files for processing. AirDrop shares files only when you select that action. Conversions run on your Mac with Apple's frameworks and a bundled, LGPL-licensed FFmpeg. There are no accounts and no analytics, and no automatic update checks. Choosing **Check for Updates…** sends a request to GitHub for public release metadata; your files are never part of that request.

macOS may request permissions for:
- **Automation › Finder**, when you first use the keyboard shortcut (to read your selection).
- **Automation › Pages / Keynote / Numbers**, only if you convert iWork files.
- **Notifications**, for job completion alerts.
- **Folder access**, when opening or saving files in protected locations such as Desktop or Documents.

## Install
**Homebrew**
```bash
brew install --cask ali-fayed/transflo/transflo
```

**Or download** the latest `Transflo-<version>-arm64.dmg` from [Releases](https://github.com/Ali-Fayed/transflo/releases/latest), open it, and drag Transflo to Applications.

> **First launch:** releases aren't notarized by Apple yet. If macOS says it can't check Transflo, open **System Settings › Privacy & Security** and click **Open Anyway** (you only do this once).

**Mac App Store** (coming soon): a sandboxed edition with the same wheels. Because of the App Store's sandbox it asks once per folder before saving next to your files, and it leaves out the Finder-selection shortcut (use **Open in Transflo** from the right-click menu instead), Pages/Keynote/Numbers conversions and the Terminal action. Updates come from the App Store.

Requires **macOS 14 Sonoma or later** on **Apple silicon**.

## FAQ
**Does it replace my files?** Conversions and edits create new files and avoid overwriting existing paths, such as `photo.png`, `photo (compressed).jpg` or `photo 2.png`. Rename changes the selected filenames; Move relocates the selected files.

**Where did the icon go?** Transflo lives in the menu bar. The first launch opens Getting Started; after you finish it, the app starts from the menu bar. Click its icon for Jobs, Settings, Getting Started and Check for Updates.

**Can I drop many files at once?** Yes. The wheel shows only what works for all of them, and the job processes them one by one with a single progress bar.

**Is it really free?** Yes: MIT-licensed, with no limits, trials or accounts.

## How it's built
Transflo is a native Swift 6 app: SwiftUI for every screen, AppKit where macOS needs it (floating panels, drag
observation, menu bar), and three local Swift packages that keep the logic independent of the UI.

```mermaid
flowchart TB
    subgraph App["Transflo (app target)"]
        Presentation["Presentation<br/>SwiftUI views · @Observable view models · coordinators"]
        DesignSystem["DesignSystem<br/>App* components · semantic tokens · Liquid Glass"]
        DI["DI<br/>AppContainer · feature factories · EditionFactory"]
    end
    Domain["TransfloDomain<br/>entities · use cases · protocols"]
    Data["TransfloData<br/>catalogs · conversion and tool engines · repositories"]
    System["TransfloSystem<br/>drag monitor · hotkeys · Finder · AirDrop · login item"]
    Presentation --> Domain
    Presentation --> DesignSystem
    DI --> Presentation
    DI --> Data
    DI --> System
    Data --> Domain
    System --> Domain
```

| Layer | Responsibility |
|---|---|
| `TransfloDomain` | Pure Swift: formats, wheel options, jobs, typed `JobError`s, use cases and the protocols everything else implements. No AppKit. |
| `TransfloData` | The JSON conversion and tool catalogs, the engines (ImageIO, AVFoundation, PDFKit, Vision, FFmpeg, iWork), and UserDefaults repositories. |
| `TransfloSystem` | macOS integration: polling the drag pasteboard, Carbon hotkeys, Finder selection, AirDrop, login items, notifications, security-scoped folder access. |
| `Transflo` | MVVM presentation with coordinators, a token-based design system (every screen composes `App*` components), and the composition root. |

**A drop, end to end.** `DragMonitor` notices a file drag and the wheel key → `WheelCoordinator` asks
`ResolveWheelOptionsUseCase` what applies to every dragged file (the catalog, filtered by Settings › Wheel) →
the petal you drop on becomes a job in `JobCenter`, which runs it with bounded concurrency → the engine writes to
private staging and publishes the result next to the original without ever replacing a file → the result disc
shows progress, then ✓ or ✕.

**Named patterns.**
- **Strategy:** conversion and tool engines; the result disc behind `JobHUDPresenting`.
- **Registry:** `ConversionCatalog`.
- **Decorator:** wheel visibility; App Store folder access.
- **Repository:** settings.
- **Factory:** DI and editions.
- **Coordinator:** wheel, editors, windows.
- **Composite:** the demo video timeline.

All dependencies are passed in through initializers, so every unit is tested with hand-written doubles.

**Engines.** Apple frameworks first; a bundled LGPL-only FFmpeg (built reproducibly from pinned, checksummed
sources) covers what they can't write. It runs as a separate signed helper process with argument arrays, never a
shell. Cancellation reaches every engine, archives are checked against expansion budgets, and documents are parsed
with external entities disabled.

**Concurrency.** Swift 6 strict concurrency, main-actor by default in the app target, typed throws in the engines
and actors where state is shared.

**Two editions, one target.** The `AppStore` build configuration adds the App Sandbox. `AppEdition` lists what each
edition may do, and `EditionFactory` is the single place that acts on it. See [docs/APP_STORE.md](docs/APP_STORE.md).

**Quality and delivery.**
- **Tests:** about 330 package tests, 170 app unit tests and 45 UI tests. UI tests are split into Fast, Extended
  and Marketing test plans, and run in an isolated preferences suite.
- **Checks:** SwiftLint strict (zero warnings), and a secrets scan in CI.
- **Project:** generated with XcodeGen, using Xcode synchronized folders.
- **Release:** a tag starts one pipeline that ships the GitHub DMG and the App Store build in parallel; Homebrew
  follows the DMG.

More detail: [architecture](docs/ARCHITECTURE.md) · [development](docs/DEVELOPING.md) · [releasing](docs/RELEASING.md).

## Build from source
See [docs/DEVELOPING.md](docs/DEVELOPING.md) to build, test and capture screenshots, and [docs/RELEASING.md](docs/RELEASING.md) to cut a release. See the [architecture overview](docs/ARCHITECTURE.md) for the app layers and persistence model.

Changes are welcome: start with [CONTRIBUTING.md](CONTRIBUTING.md). For private vulnerability reports, see [SECURITY.md](SECURITY.md).

## License
Transflo is released under the [MIT License](LICENSE). It bundles FFmpeg (LGPL 2.1+) and a few codec libraries; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for licenses, sources and the written offer.

Transflo is an independent project and isn't affiliated with Apple.
