import GlobalNewsKit
import SwiftUI

/// The reading list: stories bookmarked from the detail view.
struct SavedStoriesView: View {
    @EnvironmentObject private var store: EditionStore

    var body: some View {
        NavigationStack {
            Group {
                if store.savedStories.isEmpty {
                    ContentUnavailableView(
                        "No saved stories",
                        systemImage: "bookmark",
                        description: Text("Tap the bookmark on a story to keep it here.")
                    )
                } else {
                    List {
                        ForEach(store.savedStories) { story in
                            NavigationLink(value: story) { StoryRow(story: story) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Saved")
            .navigationDestination(for: Story.self) { StoryDetailView(story: $0) }
        }
    }
}

#Preview {
    SavedStoriesView().environmentObject(EditionStore.preview)
}
