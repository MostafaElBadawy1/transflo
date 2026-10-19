# Architecture

Transflo is a native macOS menu-bar utility. Its app target uses SwiftUI for
presentation and AppKit for windows, drag observation, and system integration.

## Layers

- `Packages/TransfloDomain`: pure models, settings contracts, and use cases.
- `Packages/TransfloData`: file conversion engines, catalogs, and persistent repositories.
- `Packages/TransfloSystem`: macOS adapters for input, Finder, login items, and notifications.
- `Transflo/Presentation`: feature view models, views, and window coordinators.
- `Transflo/DesignSystem`: localized UI components, semantic colors, and layout tokens.
- `Transflo/DI`: composition root and feature factories.

Dependencies are constructed in `AppContainer` and passed into features.
Business logic can be tested through protocol doubles without opening windows
or modifying user files. Native UI tests cover the visible flows separately.

## Editions
One target builds two editions. The direct edition (DMG, Homebrew) has every feature. The `AppStore` build
configuration adds the `APP_STORE` condition and the sandbox entitlements. `AppEdition` (domain) states what each
edition may do, and `EditionFactory` (DI) is the only place that acts on it: it drops iWork engines and the Terminal
action, skips the Finder-selection hotkey and update checks, and wraps the job scheduler in
`FolderAccessJobScheduler`, which asks for folder access before results are written. See [APP_STORE.md](APP_STORE.md).

## Preferences

Appearance and language use dedicated UserDefaults keys. Accent color, wheel
size, surface style, and reduced motion are encoded as one validated
`InterfaceCustomization` value. The composition root reads saved values before
creating windows; edits persist immediately and update the shared presentation
style. Closing a window or quitting the app does not reset preferences.

Debug UI tests use a unique `TransfloUITests.*` preferences suite. They keep that
suite across app relaunches within a test, terminate their app processes, and
remove the suite afterwards. Release builds ignore this testing override.
Tests must never reset the installed application's normal preferences.

## Settings layout

Each tab measures its natural content height independently of its scroll
viewport. The window follows the selected tab's preferred size. Tall tabs are
bounded and scroll (Customization, and Wheel with its full Convert checklist); short General, Keys and
Output tabs shrink to their content.
Only the selected page is mounted, preventing hidden native pickers from retaining
stale layers during resizing. Appearance and wheel-size controls reserve a stable
width while the preview changes. Compression and file naming share Output.
Conditional fields, language changes, and larger text must remain readable.

## Catalog and fixtures

The JSON catalogs declare supported formats and tools. Fixture tests validate
conversions, outputs and error handling with synthetic inputs generated at test time.
Third-party media, user documents and generated build artifacts do not belong in the
source tree.
