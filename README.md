# stock-predictor-ios

A SwiftUI iPhone app for the [Stock-Market-Predictor](https://github.com/andytischen/Stock-Market-Predictor)
gap model. It downloads the daily JSON snapshot that repo publishes to GitHub
Pages and shows, per index, the probability its next opening auction is up —
with the cross-asset drivers and the crude dashboard behind each call.

It also holds a second iPhone app, **Randy's Global News First** — a global news
front page over a published `news.json` edition.

## Layout

- **`Sources/GapModelKit/`** — platform-agnostic core: the `Codable` snapshot
  models (`Snapshot`, `Market`, `Driver`, `Crude`), display helpers, and
  `SnapshotClient` which fetches and decodes the JSON. Builds and tests on Linux
  (Foundation only), which is what CI runs.
- **`App/`** — the SwiftUI app (tabs: markets list → market detail, and the
  crude dashboard). Depends on `GapModelKit`. Built with Xcode.
- **`Sources/GlobalNewsKit/`** — the same for Randy's Global News First: the
  `Edition`/`Story` models, `Region`/`Topic` desks, display helpers
  (`NewsFormat`) and `EditionClient`. Foundation only, so CI tests it too.
- **`NewsApp/`** — the SwiftUI layout for **Randy's Global News First** (tabs:
  top stories → article, regions → desk feed, and saved). Depends on
  `GlobalNewsKit`, and shares `App/Views/AdSlotView.swift` with the gap-model
  app so both reserve the same advert units.
- **`project.yml`** — [XcodeGen](https://github.com/yonaskolb/XcodeGen)
  definition for both app targets; the `.xcodeproj` is generated, not committed.

## Data source

The app reads the published snapshot at the URL in `App/SnapshotStore.swift`:

```
https://andytischen.github.io/Stock-Market-Predictor/snapshot.json
```

That file is produced by `gapmodel export` and deployed by the publish workflow
in the model repo. Update `Config.snapshotURL` if your Pages path differs.

Randy's Global News First reads an edition at the URL in
`NewsApp/EditionStore.swift` (`NewsConfig.editionURL`). No newsroom feed is
published yet — `Sample/news.json` is the shape it expects and is bundled with
the app so the layout renders in Xcode previews without the network.

## Build & run

```bash
brew install xcodegen
xcodegen generate           # writes StockPredictor.xcodeproj
open StockPredictor.xcodeproj
```

Then run the `StockPredictor` scheme (iOS 16+) or the `RandysGlobalNewsFirst`
scheme (iOS 17+) on a simulator or device.

## Test the cores

```bash
swift test                  # runs GapModelKitTests and GlobalNewsKitTests
```

## Status

Gap model, phase 1 scaffold: markets list, market detail and crude dashboard
over the static daily snapshot. Not yet built here: push notifications, a home
widget, and interactive what-if shocks (which need the model repo's Option B
API).

Randy's Global News First, phase 1 layout: front page with lead story and desk
rail, per-region feeds, article page and a reading list, with advert units
reserved. Not yet built: the published edition feed itself, search, and
persisting the reading list between launches.

Not investment advice.
