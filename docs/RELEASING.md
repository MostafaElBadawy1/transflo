# Releasing Transflo

## Once
1. **Main repository:** create `github.com/Ali-Fayed/transflo` and push `main`.
2. **Tap repository:** create `github.com/Ali-Fayed/homebrew-transflo` with a `Casks/` folder. Homebrew finds it as `ali-fayed/transflo`.
3. **Build tools:** `brew install xcodegen swiftlint pkg-config meson ninja cmake nasm autoconf automake libtool`.
4. **FFmpeg:** build it with `./scripts/build-ffmpeg.sh` (about 15 minutes; checksums are verified).

## Each release
1. **Version:** bump `MARKETING_VERSION` (and `CURRENT_PROJECT_VERSION`) in `Configs/Base.xcconfig`.
2. **Tests:** run all of them (see [DEVELOPING.md](DEVELOPING.md)).
3. **Build:** run `./scripts/release.sh`. It writes three files to `build/releases/`:
   - `Transflo-<version>-arm64.dmg`
   - `transflo.rb` (the cask, with the version and SHA-256 filled in)
   - `release-notes-<version>.md`
   Set `TRANSFLO_RELEASE_OUTPUT_DIR=/absolute/output/path` to keep generated artifacts outside the checkout. Existing artifacts are never overwritten.
4. **Tag:** `git tag v<version> && git push origin v<version>`.
5. **GitHub release:** create a release for the tag, paste the release notes, and attach the DMG.
6. **Tap:** copy `transflo.rb` to `homebrew-transflo/Casks/transflo.rb`, then commit and push.
7. **Check:** `brew update && brew install --cask ali-fayed/transflo/transflo`, then launch Transflo from Applications.

## Release pipeline (all channels in parallel)
Push a tag that matches `MARKETING_VERSION` (and bump `CURRENT_PROJECT_VERSION`, which App Store Connect
requires to grow with every upload):

```bash
git tag v1.0.1 && git push origin v1.0.1
```

`.github/workflows/release.yml` then builds the media helpers once and runs, in parallel, the **GitHub release**
(DMG, notes) and the **App Store upload**; the **Homebrew cask** follows the DMG because it needs its SHA-256.
Run it from the Actions tab to ship only `github-and-homebrew` or only `app-store`.

Repository secrets (Settings › Secrets and variables › Actions):

| Secret | What |
|---|---|
| `APPLE_TEAM_ID` | Your Apple Developer team ID (developer account › Membership details) |
| `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` | An App Store Connect API key with the **Admin** role (cloud signing needs it); `ASC_KEY_P8` is the `.p8` file's text |
| `HOMEBREW_TAP_TOKEN` | A fine-grained token with *Contents: read and write* on `Ali-Fayed/homebrew-transflo` |

The same steps run on your Mac, in parallel, with your Xcode account:

```bash
TRANSFLO_TEAM_ID=<TEAMID> ./scripts/release-all.sh
```

Use `--skip-app-store` or `--skip-github` for one side. Move earlier outputs out of `build/releases` first.

## Mac App Store
The sandboxed edition is built and uploaded with `./scripts/release-appstore.sh`. One-time setup, listing copy
and review notes are in [APP_STORE.md](APP_STORE.md). Ship the same `MARKETING_VERSION` to both channels.

## In-app update checks
The menu bar’s **Check for Updates…** item checks the latest public stable release on
`Ali-Fayed/transflo`. Publish releases with a numeric `vMAJOR.MINOR.PATCH` tag matching
`MARKETING_VERSION`, and attach the installer before publishing. Drafts and prereleases
are not offered. Users open the release page to download and install the update manually.
The app only contacts GitHub when the user requests a check.

## Signing and notarization (when you have a Developer ID)
Builds are ad-hoc signed until then. The release notes and the cask tell people how to allow the first launch. Once you have a *Developer ID Application* certificate:

```bash
xcrun notarytool store-credentials transflo-notary --apple-id <your Apple ID> --team-id <TEAMID>
```

```bash
TRANSFLO_SIGN_IDENTITY="Developer ID Application: <Name> (<TEAMID>)" TRANSFLO_NOTARY_PROFILE=transflo-notary ./scripts/release.sh
```

The script then signs the helpers and the app with the hardened runtime, notarizes and staples the DMG, and drops the first-launch caveats. Your credentials stay in your keychain; the script never reads or stores them.
