# Transflo for Windows: proposed implementation plan

Status: planning proposal, 20 October 2026. No Windows implementation has been started or validated.

## Recommendation

Build a native Windows companion in this repository, preserving the macOS app. Use C# and WPF as the initial candidate for the Windows interface, with Win32 integration for the floating wheel, tray, shortcuts, and file drops. Confirm that choice through a short Windows prototype before building the editors.

This is a platform port with translated logic and replacement adapters, not a change to the Xcode build target. Reuse the product behavior, catalog data, test scenarios, translations, and visual assets where appropriate. C# cannot directly consume the existing Swift protocols or view models.

Proposed initial target: Windows 11 x64, running as a normal desktop user. Consider native ARM64 after the x64 prototype and helper dependencies work. These are proposed scope choices, not existing support commitments.

## What the current source gives us

| Existing source | Windows treatment |
| --- | --- |
| `Packages/TransfloDomain` | Translate models, wheel geometry, compatible-option intersection, output naming, settings validation, and job rules into a Windows domain library. Use existing tests as behavior specifications. |
| `Packages/TransfloData/Sources/TransfloData/Resources/catalog.json` and `tools.json` | Reuse format/tool identities and descriptions. Supply Windows engine mappings and capability filtering. |
| `Transflo/Presentation` and `Transflo/DesignSystem` | Rebuild views, editor previews, window behavior, and accessibility using the Windows UI stack. Preserve recognizable wheel behavior and English/Arabic support. |
| `Packages/TransfloSystem` | Replace macOS adapters for drag observation, clipboard, shortcuts, notifications, startup, and sharing. |
| `TransfloData` conversion/tool engines | Reimplement platform-dependent processing; translate portable parsing and argument-building logic selectively. |
| FFmpeg/ffprobe integration | Reuse processing concepts and progress parsing, with Windows executables, process management, codec detection, and revised arguments. |
| Existing unit and fixture tests | Translate important cases and add shared input/expected-result fixtures. Xcode UI tests remain macOS-specific. |

Evidence and constraints:

- `project.yml` defines only macOS application and test targets. All three package manifests declare macOS 14.
- `TransfloDomain` is mostly independent of the UI, but `Tools/AssemblySettings.swift` imports CoreGraphics and uses CGSize/CGRect. It is not already proven portable.
- `SystemDragSampler.swift` reads `NSPasteboard(name: .drag)` and `NSEvent`. `DragTracker.swift` detects a drag from pasteboard change counts. That input contract must be redesigned for Windows rather than simulated with the regular clipboard.
- `WheelDropView.swift` and the floating panel use AppKit. Wheel geometry and option selection can be translated separately from the drop target.
- `ConversionFactory.swift` constructs ImageIO, AVFoundation, PDFKit, SVG/AppKit, document, spreadsheet, archive, subtitle, FFmpeg, and iWork engines. Several require replacement even though their protocols are reusable as designs.
- `FFmpegArguments.swift` explicitly selects `h264_videotoolbox`. The current binaries and `scripts/build-ffmpeg.sh` target macOS ARM64.
- `ProcessRunner.swift` uses Darwin signals; archive processing defaults to `/usr/bin/bsdtar` and `/usr/bin/gunzip`. Windows needs different process termination, executable discovery, archive handling, and file publication.
- Catalog paths include ordered engine identifiers such as `imageio`, `pdfkit`, and `avfoundation`. Copying the JSON alone does not make these conversions work on Windows.

## Technology decision

| Option | Assessment for this app |
| --- | --- |
| C# + WPF + Win32 | Recommended prototype. WPF supports transparent custom windows and desktop drag/drop, which closely match the wheel's requirements. Build Windows styling deliberately. |
| C# + WinUI 3 + Win32 | Strong alternative, and Microsoft's recommended framework for new Windows apps. Verify transparent wheel composition, hit testing, focus behavior, and drag activation before selecting it. |
| Swift on Windows + Windows UI bindings | Possible investigation if retaining Swift source is a priority. Swift supports Windows, but that does not provide AppKit/SwiftUI or port Apple's media frameworks. Adds UI-binding and deployment questions. |
| Web-based desktop shell | Possible if web skills dominate the team, but still needs native Windows drag and window integration and provides little direct reuse of this Swift UI. |

Do not rewrite the macOS interface or create a shared Rust/C++ engine as a prerequisite. Revisit a shared compiled core only when both implementations expose enough duplicated, stable behavior to justify it.

## Proposed structure

```text
windows/
  Transflo.Windows.sln
  src/
    Transflo.Domain/       # Models, geometry, catalog rules, job contracts
    Transflo.Processing/   # Conversion adapters, helpers, staging, cancellation
    Transflo.Platform/     # Win32, drag/drop, tray, clipboard, shell integration
    Transflo.App/          # WPF wheel, settings, jobs, editors, composition root
  tests/
    Transflo.Domain.Tests/
    Transflo.Processing.Tests/
    Transflo.Platform.Tests/
shared/
  catalogs/               # Platform-neutral format/tool definitions
  fixtures/               # Behavior examples consumed by both platforms
```

Create this structure only after the feasibility prototype. Initially read the existing catalogs in place; move them to shared storage only when both build pipelines can consume them without changing macOS behavior. Keep platform-specific engine routing outside the common format definitions.

## Phase 0: prove the interaction

Timebox: approximately 3–5 engineering days, subject to Windows environment availability.

1. Set up a real Windows 11 x64 development/test machine and Windows CI. Use a VM for iteration, with physical hardware validation before release. An ARM Windows VM alone does not verify native x64 behavior.
2. Build a tray process and transparent wheel window with correct hit testing. Decorative transparency must not block unrelated desktop interaction.
3. Receive actual Explorer file drags using the Windows drag data object/drop-target APIs. Obtain paths when the drag enters the target; do not assume Windows exposes macOS-style global drag-pasteboard inspection.
4. Investigate opening the wheel during an external drag when a modifier is tapped. Any global input observation must be narrow and must not consume Explorer's ordinary keyboard behavior. Preserve the distinction between a held modifier and a new press.
5. Do not promise format-specific petals before the target receives the file data. Validate whether a neutral initial wheel followed by capability filtering is required.
6. Test focus retention, Esc cancellation, repeated drops, copy/move modifier interactions, mixed-DPI monitors, monitor edges, and non-file drags. Run without elevation.
7. Compare WPF and WinUI only as needed to resolve a concrete blocker, then record the chosen stack.

Exit gate: drag a local Explorer file, invoke the wheel, drop onto a petal, and record the correct file and choice without altering the source or interrupting the drag. If the gesture is unreliable, document the failure and use an explicit tray/shortcut-opened drop wheel for the first beta, with the interaction change clearly stated.

Global shortcut support is a separate task from observing modifier presses during a drag. Explorer-selection retrieval is also separate from registering a shortcut and can be deferred. Do not automatically map Command to the Windows key; choose configurable Windows bindings after collision testing.

## Phase 1: complete one useful workflow

Indicative effort: 1–2 engineering weeks after the prototype.

- Translate catalog lookup, compatible choices for every file, wheel geometry, output naming, job states, and cancellation rules.
- Implement one tested conversion, such as PNG to JPG, using an explicitly chosen backend.
- Connect the complete flow: tray → file drop → wheel choice → background job → progress → reveal result in Explorer.
- Stage output privately, publish without overwriting existing files, and clean up on failure/cancellation. Preserve the existing distinction between conversion/edit operations and intentional Move/Rename actions.
- Add unit tests for geometry, catalog filtering, collisions, and job transitions, plus an end-to-end fixture test for the chosen conversion.

Exit gate: an installable internal build completes that workflow on a clean Windows machine without developer tools.

## Phase 2: Windows MVP

Indicative effort: another 2–4 engineering weeks; depends on backend and codec decisions.

Include:

- File conversion for a verified subset of common image, audio, and video formats.
- Convert wheel, relevant actions wheel, progress/result feedback, Jobs, and Settings.
- Copy files, Copy Path, Reveal, and Move with explicit destination selection.
- Startup preference, persisted settings, English/Arabic, right-to-left layout, keyboard navigation, screen-reader labels, reduced motion, and light/dark appearance.
- A versioned Windows FFmpeg/ffprobe build with recorded source/configuration and notices. Replace Apple-specific encoders with tested Windows capabilities; hide routes without working encoders.
- Process execution using argument lists, asynchronous output draining, bounded cancellation of helper process trees, and output validation.
- Windows file handling: Unicode/Arabic paths, spaces, reserved filenames, case-insensitive collisions, locked files, read-only locations, long paths, and duplicate batches.
- A repeatable installer/update strategy, clean uninstall, and Windows CI for build/tests/artifact creation. Select signing and distribution before a public beta.

Defer:

- Full parity with the README's 262 conversion routes and 26 tools.
- Full editor set, background removal, PDF redaction, complex office conversion, and advanced PDF extraction.
- Explorer context-menu integration and selected-file hotkey until their deployment and selection behavior are proven.
- Native ARM64 distribution until the application and every helper are verified.

Exit gate: clean-machine install, successful fixture conversions for every advertised route, cancellation and collision tests, keyboard and Arabic smoke tests, and no modification of originals during conversions/edits.

## Phase 3: expand feature coverage

Add focused editors and the float shelf in small groups. Choose and validate image, PDF, document, archive, and background-removal libraries individually. Match preview processing to export processing.

| macOS feature | Windows plan |
| --- | --- |
| AirDrop | Omit initially; evaluate a Windows sharing action separately. |
| Finder selection / Quick Action | Explorer integration; separate feature with dedicated selection and packaging tests. |
| Terminal / iTerm / Ghostty / Warp opening | Windows Terminal or configured shell, with proper argument handling. |
| Pages / Keynote / Numbers automation | Omit initially; investigate tested import alternatives only when needed. |
| ImageIO / CoreImage / Vision | Choose Windows or portable processing backends; verify codec and model availability. |
| PDFKit / Quartz | Select a PDF backend per required operation. Rendering support alone does not establish editing or redaction support. |
| VoiceOver / macOS haptics | Windows UI Automation/Narrator and visual feedback; haptics optional. |
| UserDefaults / login items / notifications | Windows-local settings and native startup/notification adapters. |

PDF redaction requires tests proving covered text is removed from extraction and the saved document, beyond placing a rectangle over it. Archive support must preserve traversal, link, and extraction-budget protections while handling Windows paths and reparse points.

## First implementation backlog

1. `WIN-001`: Windows environment and prototype build pipeline.
2. `WIN-002`: Transparent wheel and Explorer file-drop reception.
3. `WIN-003`: External-drag activation investigation and recorded acceptance results.
4. `WIN-004`: Stack decision and agreed first-beta gesture.
5. `WIN-005`: Domain translation and shared behavior fixtures.
6. `WIN-006`: First conversion with safe staging, cancellation, and progress.
7. `WIN-007`: Capability-based catalog, including Windows engine mapping.
8. `WIN-008`: Jobs, settings, actions, localization, and accessibility.
9. `WIN-009`: Helper packaging, clean-machine installation, signing, and update decision.
10. `WIN-010`: Beta validation and a published feature matrix based on tested routes.

Indicative total to a limited beta: roughly 4–8 engineering weeks for an experienced Windows developer after environment setup, if the gesture prototype succeeds. This is an effort estimate, not a delivery commitment; full feature parity needs separate estimation after backend selection. Work on the macOS machine can prepare source and contracts, but Windows interaction, installation, and runtime validation require Windows.

## Reference documentation

- [WPF custom and transparent windows](https://learn.microsoft.com/en-us/dotnet/desktop/wpf/windows/)
- [WPF drag and drop](https://learn.microsoft.com/en-us/dotnet/desktop/wpf/advanced/drag-and-drop)
- [Microsoft Windows app development](https://learn.microsoft.com/en-us/windows/apps/)
- [Windows Shell drag-and-drop data and drop targets](https://learn.microsoft.com/en-us/windows/win32/shell/dragdrop)
- [RegisterHotKey](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerhotkey)
- [Swift platform support](https://www.swift.org/platform-support/)
- [Swift on Windows installation](https://www.swift.org/install/windows/)
- [FFmpeg distribution and licensing guidance](https://www.ffmpeg.org/legal.html)
