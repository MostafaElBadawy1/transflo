#!/usr/bin/env bash
# Captures the README screenshots into docs/screenshots/ from a fresh Debug build.
#   scripts/capture-screenshots.sh
# Needs the screen unlocked; Transflo's windows appear over a branded backdrop for several minutes.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/docs/screenshots"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/transflo-shots.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

# Regenerate so existing checkouts also receive the current test-plan references.
"$ROOT/scripts/bootstrap.sh"
TEST_RUNNER_TRANSFLO_SCREENSHOTS=1 xcodebuild test -quiet -project "$ROOT/Transflo.xcodeproj" -scheme Transflo -testPlan Marketing \
  -destination 'platform=macOS' -derivedDataPath "${TRANSFLO_DERIVED_DATA:-$WORK/DerivedData}" \
  -clonedSourcePackagesDirPath "${TRANSFLO_PACKAGE_CACHE:-$WORK/packages}" -resultBundlePath "$WORK/shots.xcresult" \
  -parallel-testing-enabled NO -enableCodeCoverage NO
xcrun xcresulttool export attachments --path "$WORK/shots.xcresult" --output-path "$WORK/attachments" >/dev/null

mkdir -p "$OUT"
MARKETING="$ROOT/build/marketing/captures"
mkdir -p "$MARKETING"
python3 -I - "$WORK/attachments" "$OUT" "$MARKETING" <<'PY'
import json, pathlib, shutil, sys
source, destination, marketing = (pathlib.Path(argument) for argument in sys.argv[1:4])
count = extra = 0
for test in json.loads((source / "manifest.json").read_text()):
    for attachment in test["attachments"]:
        name = attachment.get("suggestedHumanReadableName", "")
        if name.startswith("readme-"):
            target = destination / (name.removeprefix("readme-").split("_0_")[0] + ".png")
            shutil.copyfile(source / attachment["exportedFileName"], target)
            count += 1
        elif name.startswith("marketing-"):
            # Full-resolution customization shots for marketing images; not README assets.
            target = marketing / (name.removeprefix("marketing-").split("_0_")[0] + ".png")
            shutil.copyfile(source / attachment["exportedFileName"], target)
            extra += 1
print(f"Saved {count} screenshots to {destination} and {extra} marketing captures to {marketing}")
PY
# Keep the repository light: at most 1400 px on the long side.
sips -Z 1400 "$OUT"/*.png >/dev/null
cp "$ROOT/Transflo/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png" "$OUT/icon.png"
