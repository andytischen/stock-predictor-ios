# stock-predictor-ios

A SwiftUI iPhone app for the [Stock-Market-Predictor](https://github.com/andytischen/Stock-Market-Predictor)
gap model. It downloads the daily JSON snapshot that repo publishes to GitHub
Pages and shows, per index, the probability its next opening auction is up —
with the cross-asset drivers and the crude dashboard behind each call.

## Layout

- **`Sources/GapModelKit/`** — platform-agnostic core: the `Codable` snapshot
  models (`Snapshot`, `Market`, `Driver`, `Crude`), display helpers, and
  `SnapshotClient` which fetches and decodes the JSON. Builds and tests on Linux
  (Foundation only), which is what CI runs.
- **`App/`** — the SwiftUI app (tabs: markets list → market detail, and the
  crude dashboard). Depends on `GapModelKit`. Built with Xcode.
- **`App/Ads/`** — the ad seam: `AdSlot` sizes the reserved space, `AdProvider`
  supplies the creative for a slot. `PlaceholderAdProvider` (the default) never
  fills, so slots show a labelled placeholder; `MockAdProvider` fills every slot
  for layout checks. Linking a network means writing one `AdProvider` and
  injecting it in `StockPredictorApp` — no view changes.
- **`project.yml`** — [XcodeGen](https://github.com/yonaskolb/XcodeGen)
  definition; the `.xcodeproj` is generated, not committed.

## Data source

The app reads the published snapshot at the URL in `App/SnapshotStore.swift`:

```
https://andytischen.github.io/Stock-Market-Predictor/snapshot.json
```

That file is produced by `gapmodel export` and deployed by the publish workflow
in the model repo. Update `Config.snapshotURL` if your Pages path differs.

## Build & run

```bash
brew install xcodegen
xcodegen generate           # writes StockPredictor.xcodeproj
open StockPredictor.xcodeproj
```

Then run the `StockPredictor` scheme on an iOS 16+ simulator or device.

## Test the core

```bash
swift test                  # runs GapModelKitTests (no Xcode needed)
```

## Status

Phase 1 scaffold: markets list, market detail and crude dashboard over the
static daily snapshot. Not yet built here: push notifications, a home widget,
and interactive what-if shocks (which need the model repo's Option B API).

Not investment advice.
