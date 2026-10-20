# Changelog

All notable changes to Transflo are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.1] - 2026-10-20

### Added
- **Recipes**: chain convert, compress, resize, remove metadata and rename into one option on the
  Tools wheel. Find them in Settings › Recipes, or **Recipes…** in the menu-bar menu.
- **Watch folders**: convert, compress or run a recipe on every new file that lands in a folder.
- **Shortcuts, Spotlight and Siri**: Convert Files, Compress Files and Run Recipe actions.
- **On-device intelligence**: Extract Text (OCR, including scanned PDFs) and Upscale 2× (MetalFX) on
  every Mac; Describe Image (alt text to the clipboard) and Smart Rename (suggested names you review
  first) on macOS 26 with Apple Intelligence. Nothing leaves your Mac.
- **Icons**: convert any image to a multi-size ICO or ICNS, and icons back to PNG, JPG and more.
- **GIF compression**: shared palettes, fewer colors and smaller frames, to a level or a size limit.
- Drops straight from Safari, Photos and Mail, and **Convert Clipboard…** for a copied image or files.
- Starred options, last choice first and optional frequency ordering on every wheel.
- Batches convert several files at once, Jobs shows the time left, and **Undo** moves a job's new files
  to the Trash.

### Changed
- Archive replaces Float on the Actions wheel and creates a ZIP from selected files and folders.
- Saved recipes remain available for already-matching conversion formats and cannot be stranded by stale visibility settings.
- Extract ZIP, RAR, TAR and GZIP archives directly from the Tools wheel into a new folder.
- The Tools wheel combines related operations into compact groups, with hover/click navigation and
  Back. Individual tools retain their visibility, favorites and editors; duplicate entries are removed.
- Back waits one second on hover, then pauses before another group opens; Recipes has its own entry whenever compatible saved recipes exist. Onboarding explains the grouped wheel with the current selection styling.
- General now contains only Best, Balanced and Smaller compression defaults. The Formats tab is removed; old size/percentage defaults safely become Balanced.
- Smaller wheel rings, icons and labels keep the menu lighter without crowding tool names.
- Hardware video encoding (VideoToolbox) for size limits, HEVC for the "Smaller file" level and
  hardware decoding, so video jobs finish much sooner.
- Settings › Formats is one column with a page per format; focus rings and sliders follow the accent
  color, and the trim and range sliders track the pointer exactly.
- Labels on wheels with two or three options sit in the middle of their petal.

### Fixed
- Undo checks the identity and saved contents of generated results before moving them to the Trash.
- Shortcuts rejects unsafe filenames and stages identically named inputs separately.
- Recipes honor cancellation before publishing and retain completed results if publication partly fails.
- Smart Rename preserves unchanged names across folders when no useful suggestion is available.
- PDF text extraction recognizes scanned pages alongside selectable pages and continues past page 20.
- Watch folders recognize replacement files, avoid duplicate queued work, and skip Transflo outputs
  before their jobs finish.
- Promised drops collect every file from legacy multi-file receivers and recheck the delivered selection.

## [1.0.0] - 2026-10-19
First public release.

### Added
- Drag-and-drop wheels at the pointer: **⇧ Convert** (262 conversions across images, audio, video,
  documents, PDF, slides, spreadsheets, subtitles and archives), **⌘ Tools** (26 tools) and **⌃ Actions**
  (AirDrop, Float shelf, Copy, Move, Copy Path, Terminal).
- Focused editors for crop, background, annotate, redact, page reorganizing, metadata, rename and more.
- Compression to a quality preset or an exact size limit, and a choice of output name styles.
- A result disc where the wheel was: it fills while a job runs and ends in a check or a cross.
- Settings › Wheel to show only the formats, tools and actions you use.
- Keyboard path (⌥⌘Return on a Finder selection) and **Open in Transflo** in the Services menu.
- Jobs window, Getting Started tour, English and Arabic with right-to-left layout, light and dark,
  accent colors, Liquid Glass, VoiceOver and Reduce Motion support.
- Distribution as a DMG, a Homebrew cask and a sandboxed Mac App Store edition.
- A daily update check that sends a notification when a new version is out, plus **Check for Updates…**
  and a switch in Settings › About. The DMG/Homebrew edition opens the GitHub release; the App Store
  edition opens Transflo's App Store page, and the App Store installs the update.

[Unreleased]: https://github.com/Ali-Fayed/transflo/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/Ali-Fayed/transflo/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Ali-Fayed/transflo/releases/tag/v1.0.0
