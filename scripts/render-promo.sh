#!/usr/bin/env bash
# Renders the marketing video from docs/screenshots into build/marketing/transflo-promo.mp4, plus
# transflo-demo.webp, the 960-px animated copy the README plays inline (GitHub won't play repo videos).
#
#   scripts/render-promo.sh                  # the video and the README animation
#   scripts/render-promo.sh --still 7.5      # one frame as build/marketing/still-7.5.png
#   scripts/render-promo.sh --appstore       # Mac App Store screenshots in build/marketing/appstore
#   scripts/render-promo.sh --customization  # customization PNGs (landscape and square) in build/marketing/customization
#   scripts/render-promo.sh --readme         # designed feature panels for the README
#
# Refresh the screenshots first (scripts/capture-screenshots.sh) so the video shows the current UI.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/marketing"
mkdir -p "$OUT"
xcrun swiftc -O -swift-version 5 "$ROOT"/scripts/marketing/*.swift -o "$OUT/promo"

if [[ "${1:-}" == "--readme" ]]; then
  "$OUT/promo" readme "$ROOT" "$ROOT/docs/features/visuals"
elif [[ "${1:-}" == "--customization" ]]; then
  [[ -d "$OUT/captures" ]] || { echo "run scripts/capture-screenshots.sh first (build/marketing/captures)" >&2; exit 1; }
  rm -rf "$OUT/customization"
  "$OUT/promo" customization "$ROOT" "$OUT/customization"
elif [[ "${1:-}" == "--appstore" ]]; then
  rm -rf "$OUT/appstore"
  "$OUT/promo" appstore "$ROOT" "$OUT/appstore"
elif [[ "${1:-}" == "--still" ]]; then
  [[ -n "${2:-}" ]] || { echo "usage: $0 --still <seconds>" >&2; exit 64; }
  "$OUT/promo" still "$ROOT" "$OUT/still-$2.png" "$2"
  echo "Wrote $OUT/still-$2.png"
else
  rm -f "$OUT/transflo-promo.mp4" "$OUT/transflo-demo.webp"
  "$OUT/promo" render "$ROOT" "$OUT/transflo-promo.mp4"
  FFMPEG="$ROOT/Vendor/ffmpeg/bin/ffmpeg"
  [[ -x "$FFMPEG" ]] || { echo "Skipping transflo-demo.webp: run scripts/build-ffmpeg.sh first" >&2; exit 0; }
  "$FFMPEG" -v error -i "$OUT/transflo-promo.mp4" -vf "fps=15,scale=960:-1:flags=lanczos" \
    -c:v libwebp -quality 72 -compression_level 6 -loop 0 -an "$OUT/transflo-demo.webp"
  echo "Wrote $OUT/transflo-demo.webp"
fi
