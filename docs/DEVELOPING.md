# Developing Transflo

## Requirements
- macOS 14+ on Apple silicon
- Xcode 26 or newer, plus `brew install xcodegen swiftlint`

## Build
```bash
brew install pkg-config meson ninja cmake nasm autoconf automake libtool
```

```bash
./scripts/build-ffmpeg.sh
```

```bash
./scripts/bootstrap.sh
```

```bash
open Transflo.xcodeproj
```

- **`build-ffmpeg.sh`** builds the LGPL-only ffmpeg into `Vendor/ffmpeg/bin`. It verifies pinned checksums and takes about 15 minutes, once.
- **`bootstrap.sh`** generates `Transflo.xcodeproj` from `project.yml`. The project file isn't committed.
  The post-generation step converts physical directories to Xcode synchronized folders, preserving target
  exclusions and shared UI-test sources. Added or removed files appear automatically in the navigator.
  Python 3 and macOS `plutil` are required; no additional Python packages are needed.

## Test
```bash
swiftlint lint --strict
```

```bash
for p in Packages/*/; do
  swift test --package-path "$p" --scratch-path "${TMPDIR:-/tmp}/transflo-tests-$(basename "$p")" || exit 1
done
```

```bash
xcodebuild test -project Transflo.xcodeproj -scheme Transflo -testPlan Fast -destination 'platform=macOS' \
  -derivedDataPath "${TMPDIR:-/tmp}/transflo-tests-xcode"
```

Xcode's **Product → Test Plan** menu selects the same checked-in plans:

| Plan | Coverage | When to run |
| --- | --- | --- |
| Fast (default) | All app unit tests and 22 UI regressions: persistence, sizing, language switching, keyboard, onboarding, wheels, jobs and shelf | Cmd-U and every pull request |
| Extended | 18 additional UI tests: every remaining editor, locale/theme variants, all-tab sizing, multi-file wheels and automatic result dismissal | Before merging; CI on `main` and manual runs |
| Marketing | 5 screenshot flows for README assets; no unit tests | Explicit capture only |

Fast and Extended are disjoint; run both for all functional UI coverage. Package
tests remain separate. To run only the remaining UI tests:

```bash
xcodebuild test -project Transflo.xcodeproj -scheme Transflo -testPlan Extended \
  -destination 'platform=macOS' -parallel-testing-enabled NO \
  -derivedDataPath "${TMPDIR:-/tmp}/transflo-tests-xcode"
python3 scripts/validate-ui-test-plans.py
```

The validator rejects missing, duplicated or stale UI selections when tests change.
Success screenshots are off by default; XCTest's automatic failure diagnostics stay
enabled. Set `TEST_RUNNER_TRANSFLO_UI_SCREENSHOTS=1` for optional diagnostic images.
Keep the Mac unlocked and idle, and use one UI worker (`-parallel-testing-enabled NO`).

Build and signing check:
```bash
xcodebuild build -project Transflo.xcodeproj -scheme Transflo -configuration Release \
  -destination 'generic/platform=macOS' -derivedDataPath "${TMPDIR:-/tmp}/transflo-tests-xcode"
codesign --verify --deep --strict "${TMPDIR:-/tmp}/transflo-tests-xcode/Build/Products/Release/Transflo.app"
```

UI tests use an isolated preference suite, including across relaunches, so color,
appearance, key, and output checks do not change your installed app’s settings.
Debug UI tests temporarily give Transflo a Dock presence so macOS activation reliably
brings its windows forward. Release builds keep the normal menu-bar behavior.
The optional iWork integration matrix needs Pages, Keynote and Numbers installed
and Automation consent. Run it with `TRANSFLO_IWORK_TESTS=1 swift test --package-path
Packages/TransfloData --scratch-path "${TMPDIR:-/tmp}/transflo-tests-TransfloData"`.
The ordinary conversion matrix generates its own synthetic inputs and, with the bundled FFmpeg helpers, checks
every supported path except iWork Automation and legacy PPT/XLS input. The opt-in
[release verification suite](testing/release-verification.md) covers those too, with private fixtures.

`-TransfloOpenWelcome` always replays Getting Started from page 1, even after completion.
In Debug, `-TransfloOnboardingPage <1–5>` opens a particular page for inspection.
The ordinary launch shows the tour only until Done is selected.

UI tests drive the app through debug-only launch arguments (`-TransfloPreviewWheel`, `-TransfloPreviewEditor`, `-TransfloPreviewJobs` and others; see `Transflo/App/LaunchArgument.swift`), because real Finder drags can't be automated.

## README screenshots
```bash
./scripts/capture-screenshots.sh
```

Selects the Marketing test plan (`TRANSFLO_SCREENSHOTS=1` is set by the plan) and writes `docs/screenshots/*.png`.

- **Floating panels** (wheel, result disc, shelf) are shot over a branded backdrop (`-TransfloScreenshotBackdrop`), so your desktop never shows.
- **Windows** are shot as they are.
- **Keep the screen unlocked and idle** while it runs (several minutes).
- Debug screenshot runs temporarily give Transflo a Dock presence for reliable activation.
- Captures retry brief focus changes, then fail if Transflo loses foreground focus. Visually inspect every image before publishing; system notifications can still cover a window.
- Includes light/dark wheels, Customization, Output, Getting Started, Crop and Add Background.
- Includes all five onboarding pages in English/light and Arabic/dark.
- Build products and package caches use a temporary directory that is removed on exit.
  Set `TRANSFLO_DERIVED_DATA` and `TRANSFLO_PACKAGE_CACHE` to reuse caches outside the repository.

## Demo video
```bash
./scripts/render-promo.sh
```

```bash
./scripts/render-promo.sh --still 6.6
```

Renders the 42-second demo from `docs/screenshots` into `build/marketing/`:
- **`transflo-promo.mp4`:** 1080p, 30 fps, silent.
- **`transflo-demo.webp`:** a 960 px, 15 fps animated copy made with the bundled ffmpeg. The README shows this one, because GitHub doesn't play videos stored in the repository.

- **Engine:** a small Swift program in `scripts/marketing/` that draws with AppKit and encodes with AVFoundation. No extra dependencies.
- **Scenes:** the order, copy and screenshots are in `PromoStoryboard.swift`. Each scene is its own file.
- **Stills:** `--still <seconds>` writes one frame as a PNG, for checking a scene or making the poster.
- **Publishing:** copy both files to `docs/media/`. Keep the WebP under about 10 MB so GitHub serves it inline.
- **Screenshots first:** after UI changes, run `capture-screenshots.sh` before rendering, so the video shows the current UI.

## App Store edition
```bash
xcodebuild build -project Transflo.xcodeproj -scheme "Transflo App Store" -configuration AppStore -destination 'generic/platform=macOS'
```

Builds the sandboxed edition (ad-hoc signed locally). Run it from the build folder to try the sandbox: it asks for
folder access on the first drop from each folder. Release steps are in [APP_STORE.md](APP_STORE.md).

## DMG installer
```bash
./scripts/build-dmg.sh
```

```bash
./scripts/build-dmg.sh --app /path/to/Transflo.app
```

- **Output:** writes `build/releases/Transflo-<version>-<architecture>.dmg` and never overwrites an existing one. `--output-dir` changes the location.
- **Look:** the window follows the system appearance; `--style branded` uses the illustrated background instead.
- **Python:** needed for Finder layout metadata. The two pinned dependencies in `scripts/dmg/requirements.txt` install into a temporary environment and are removed afterwards. Set `TRANSFLO_DMG_PYTHON` to reuse an interpreter that already has them.
- **Contents:** the installer carries the license, the third-party notices and the ffmpeg build info, with local paths removed.

For full releases (cask, notes, notarization), see [RELEASING.md](RELEASING.md).

## Layout
| Path | What |
|---|---|
| `Transflo/` | App target: DesignSystem (tokens, `App*` primitives and components), Presentation (MVVM + Coordinators), DI, localization (en/ar) |
| `Packages/TransfloDomain` | Pure Swift entities, use cases and protocols, plus `TransfloDomainTestSupport` doubles |
| `Packages/TransfloData` | Catalogs, conversion and tool engines (ImageIO, AVFoundation, PDFKit, Vision, ffmpeg, iWork), file actions |
| `Packages/TransfloSystem` | macOS integration: drag monitor, hotkey, pasteboard, terminals, AirDrop, login item, notifications |
| `scripts/` | Bootstrap, LGPL ffmpeg build, DMG, release, screenshots, demo video |
| `docs/ARCHITECTURE.md` | App layers, persistence, and test isolation |

## Continuous integration

`.github/workflows/ci.yml` runs on pull requests, pushes to `main`, and manual dispatch.
It uses the macOS 26 arm64 image's default Xcode (26 or newer), validates the workflow,
lints Swift, scans Git history for secrets, and builds the pinned LGPL media helpers.
Only helper binaries and build provenance are cached, keyed by the toolchain, build
script and source checksums; Xcode build products are never restored from cache.

Package tests run serially to avoid contention between encoders. App unit and native
UI tests run in separate steps with one desktop worker. Pull requests run Fast;
`main` and manual runs also run Extended, without repeating Fast tests. Optional iWork Automation
and README marketing captures remain local opt-in checks, as documented above.

The final step builds an ad-hoc-signed Release DMG and a Homebrew cask without
publishing them. Download **Transflo-arm64-review-build** from the run to inspect them.
Logs and `.xcresult` bundles are uploaded even on failure and retained for seven days.
No signing certificates, notarization credentials or write permissions are needed.
