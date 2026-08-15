import SwiftUI

@main
struct StockPredictorApp: App {
    @StateObject private var store = SnapshotStore()

    /// One provider for the whole app, so the SDK is started once. Each slot
    /// still renders its own ad view. Falls back to placeholders wherever
    /// Google Mobile Ads isn't linked in.
    private let adProvider: AdProvider = {
        #if canImport(GoogleMobileAds)
        return AdMobAdProvider()
        #else
        return PlaceholderAdProvider()
        #endif
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environment(\.adProvider, adProvider)
                .task { await store.load() }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: SnapshotStore

    var body: some View {
        TabView {
            MarketsListView()
                .bannerAdSlot()
                .tabItem { Label("Markets", systemImage: "chart.line.uptrend.xyaxis") }
            CrudeDashboardView()
                .bannerAdSlot()
                .tabItem { Label("Crude", systemImage: "drop.fill") }
        }
    }
}
