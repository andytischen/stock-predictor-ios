import SwiftUI

@main
struct StockPredictorApp: App {
    @StateObject private var store = SnapshotStore()

    /// One provider for the whole app: slots share its per-slot views, so the
    /// banner attached to each tab is a single request, not one per tab.
    private let adProvider: AdProvider = PlaceholderAdProvider()

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
