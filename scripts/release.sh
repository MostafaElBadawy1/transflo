#!/usr/bin/env bash
# Builds a Transflo release into build/releases: the DMG, its SHA-256, a Homebrew cask and release notes.
#
#   scripts/release.sh                     # ad-hoc signed (no Apple Developer account needed)
#   TRANSFLO_SIGN_IDENTITY="Developer ID Application: Name (TEAMID)" \
#   TRANSFLO_NOTARY_PROFILE=transflo-notary scripts/release.sh
#                                          # Developer ID signed, notarized and stapled
#
# Create the notary profile once with your own credentials (they stay in your keychain):
#   xcrun notarytool store-credentials transflo-notary --apple-id <you> --team-id <TEAMID>
# Existing artifacts are never overwritten.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${TRANSFLO_RELEASE_OUTPUT_DIR:-$ROOT/build/releases}"
SIGN="${TRANSFLO_SIGN_IDENTITY:-}"
NOTARY="${TRANSFLO_NOTARY_PROFILE:-}"

fail() { echo "error: $*" >&2; exit 1; }
[[ -z "$NOTARY" || -n "$SIGN" ]] || fail "notarization needs TRANSFLO_SIGN_IDENTITY (a Developer ID Application identity)"
for binary in ffmpeg ffprobe; do
  [[ -x "$ROOT/Vendor/ffmpeg/bin/$binary" ]] || fail "run scripts/build-ffmpeg.sh first ($binary missing)"
done

VERSION="$(awk -F' = ' '$1 == "MARKETING_VERSION" { print $2 }' "$ROOT/Configs/Base.xcconfig")"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "unexpected MARKETING_VERSION '$VERSION'"
DMG="$OUT/Transflo-$VERSION-arm64.dmg"
CASK="$OUT/transflo.rb"
NOTES="$OUT/release-notes-$VERSION.md"
for artifact in "$DMG" "$CASK" "$NOTES"; do
  [[ ! -e "$artifact" ]] || fail "$artifact already exists; move it aside first"
done

WORK="$(mktemp -d "${TMPDIR:-/tmp}/transflo-release.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

echo "Building Transflo $VERSION (Release)…"
[[ -d "$ROOT/Transflo.xcodeproj" ]] || "$ROOT/scripts/bootstrap.sh"
xcodebuild build -quiet -project "$ROOT/Transflo.xcodeproj" -scheme Transflo -configuration Release \
  -destination 'generic/platform=macOS' -derivedDataPath "$WORK/DerivedData" \
  CLANG_MODULE_CACHE_PATH="$WORK/ModuleCache"
APP="$WORK/DerivedData/Build/Products/Release/Transflo.app"
[[ -d "$APP" ]] || fail "the Release build produced no app"

if [[ -n "$SIGN" ]]; then
  echo "Signing with $SIGN (hardened runtime)…"
  for helper in ffmpeg ffprobe; do
    codesign --force --options runtime --timestamp --sign "$SIGN" "$APP/Contents/Helpers/$helper"
  done
  codesign --force --options runtime --timestamp \
    --entitlements "$ROOT/Transflo/Resources/Transflo.entitlements" --sign "$SIGN" "$APP"
fi
codesign --verify --deep --strict "$APP"

mkdir -p "$OUT"
"$ROOT/scripts/build-dmg.sh" --app "$APP" --output-dir "$OUT"
[[ -f "$DMG" ]] || fail "expected $DMG"

if [[ -n "$NOTARY" ]]; then
  echo "Notarizing (this can take a few minutes)…"
  codesign --sign "$SIGN" --timestamp "$DMG"
  xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY" --wait
  xcrun stapler staple "$DMG"
  xcrun stapler validate "$DMG"
  FIRST_LAUNCH=""
  CAVEATS=""
else
  FIRST_LAUNCH=$'\n> **First launch:** this build isn\'t notarized yet. If macOS says it can\'t check Transflo, open System Settings › Privacy & Security and click **Open Anyway** (once).\n'
  CAVEATS=$'\n  caveats <<~EOS\n    Transflo is not notarized yet. On first launch, if macOS blocks it, open\n    System Settings › Privacy & Security and click "Open Anyway" (once).\n  EOS\n'
fi

SHA="$(shasum -a 256 "$DMG" | awk '{ print $1 }')"
render() {
  python3 -I - "$1" "$2" "$VERSION" "$SHA" "$CAVEATS" "$FIRST_LAUNCH" <<'PY'
import sys
template, output, version, sha, caveats, first_launch = sys.argv[1:7]
text = open(template, encoding="utf-8").read()
for key, value in {"@VERSION@": version, "@SHA256@": sha, "@CAVEATS@": caveats, "@FIRST_LAUNCH@": first_launch}.items():
    text = text.replace(key, value)
with open(output, "x", encoding="utf-8") as handle:
    handle.write(text)
PY
}
render "$ROOT/scripts/release/transflo.rb.in" "$CASK"
render "$ROOT/scripts/release/release-notes.md.in" "$NOTES"

echo
echo "Release $VERSION ready in $OUT:"
echo "  $(basename "$DMG")  sha256 $SHA"
echo "  $(basename "$CASK")  (copy to the Ali-Fayed/homebrew-transflo tap as Casks/transflo.rb)"
echo "  $(basename "$NOTES")"
