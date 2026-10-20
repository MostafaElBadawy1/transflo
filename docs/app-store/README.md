# App Store listing assets

The English (U.S.) description and promotional text live beside this file. They describe the sandboxed App Store edition, including Recipes, watch folders, archives and on-device tools. They omit the floating shelf, Terminal action, Finder-selection shortcut and iWork automation.

## Promotional screenshots

Run `scripts/render-promo.sh --appstore` to render ten ordered 2880 × 1800 opaque PNGs in `build/marketing/appstore/`. The renderer composes actual app captures with explanatory headlines. It uses the shipping app’s system typography, dark surfaces and teal accent.

Most inputs come from `scripts/capture-screenshots.sh`. To refresh the four App Store-specific inputs, run the isolated capture below with an unlocked Mac. APP_STORE excludes the Terminal action from the captured wheel. Use a fresh result-bundle path each time.

```bash
TEST_RUNNER_TRANSFLO_SCREENSHOTS=1 xcodebuild test -quiet \
  -project Transflo.xcodeproj -scheme Transflo -testPlan Marketing \
  -destination 'platform=macOS' -derivedDataPath build/appstore-captures \
  -resultBundlePath build/appstore-captures.xcresult \
  -only-testing:TransfloUITests/MarketingScreenshotUITests/testAppStoreFeatureScreens \
  -parallel-testing-enabled NO -enableCodeCoverage NO \
  'SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) DEBUG APP_STORE'
```

Export the four `readme-` attachments with `xcrun xcresulttool export attachments`, using the name mapping in `scripts/capture-screenshots.sh`, into `docs/screenshots/`. These captures use synthetic files and isolated preferences. Ordinary screenshot runs skip this edition-specific capture.

Upload the ten numbered PNGs in order for the Mac device size. [Apple’s screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications) permit up to ten images and include 2880 × 1800 for Mac. Check the description (4,000 characters) and promotional text (170 characters) before saving the localization. Generated upload bundles and credentials belong outside version control.
