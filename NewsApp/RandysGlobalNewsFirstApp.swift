import SwiftUI

@main
struct RandysGlobalNewsFirstApp: App {
    @StateObject private var store = EditionStore()

    var body: some Scene {
        WindowGroup {
            NewsRootView()
                .environmentObject(store)
                .task { await store.load() }
        }
    }
}

struct NewsRootView: View {
    @EnvironmentObject private var store: EditionStore

    var body: some View {
        TabView {
            TopStoriesView()
                .bannerAdSlot()
                .tabItem { Label("Top stories", systemImage: "newspaper") }
            RegionsView()
                .bannerAdSlot()
                .tabItem { Label("Regions", systemImage: "globe") }
            SavedStoriesView()
                .bannerAdSlot()
                .tabItem { Label("Saved", systemImage: "bookmark") }
        }
    }
}

#Preview {
    NewsRootView().environmentObject(EditionStore.preview)
}
