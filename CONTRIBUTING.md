# Contributing

Start with [development setup](docs/DEVELOPING.md) and the
[architecture overview](docs/ARCHITECTURE.md).

## Before opening a pull request

1. Generate the project with `./scripts/bootstrap.sh`.
2. Run `swiftlint lint --strict`.
3. Run the package-test loop in [development setup](docs/DEVELOPING.md#test).
4. Run `xcodebuild test -project Transflo.xcodeproj -scheme Transflo -destination 'platform=macOS'`.
5. Verify a Release build with `xcodebuild build -project Transflo.xcodeproj -scheme Transflo -configuration Release`.

Keep changes focused and include the checks you ran. New behavior should have
regression coverage. Keep UI copy localized in English and Arabic, preserve
keyboard and accessibility behavior, and use the existing design-system tokens.
UI tests need an unlocked interactive Mac session; screenshot-generation tests
run separately through `scripts/capture-screenshots.sh`.

Do not include credentials, signing assets, personal file paths, private user
files, generated projects, build products, or third-party reference artwork.
Use synthetic fixtures and the isolated test preference store.

See [SECURITY.md](SECURITY.md) for vulnerability reports and
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for bundled software notices.
