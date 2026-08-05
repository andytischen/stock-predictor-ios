import SwiftUI

@main
struct StockPredictorApp: App {
    @StateObject private var store = SnapshotStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .task { await store.load() }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: SnapshotStore

    var body: some View {
        TabView {
            MarketsListView()
                .tabItem { Label("Markets", systemImage: "chart.line.uptrend.xyaxis") }
            CrudeDashboardView()
                .tabItem { Label("Crude", systemImage: "drop.fill") }
        }
    }
}
