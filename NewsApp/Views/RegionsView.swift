import GlobalNewsKit
import SwiftUI

/// The desks tab: every region in the edition with a count, leading into that
/// desk's feed.
struct RegionsView: View {
    @EnvironmentObject private var store: EditionStore

    var body: some View {
        NavigationStack {
            Group {
                if let edition = store.edition {
                    List {
                        Section {
                            RefreshFailureNotice()
                        }
                        ForEach(edition.regions, id: \.self) { region in
                            NavigationLink(value: region) {
                                LabeledContent {
                                    Text("\(edition.stories(in: region).count)")
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                } label: {
                                    Label(region.title, systemImage: region.symbolName)
                                }
                            }
                        }
                    }
                } else {
                    EditionLoadingView()
                }
            }
            .navigationTitle("Regions")
            .navigationDestination(for: Region.self) { RegionFeedView(region: $0) }
            .navigationDestination(for: Story.self) { StoryDetailView(story: $0) }
            .refreshable { await store.load() }
        }
    }
}

/// One desk's stories, newest treatment first, with an advert after the top few.
struct RegionFeedView: View {
    @EnvironmentObject private var store: EditionStore
    let region: Region

    private var stories: [Story] { store.edition?.stories(in: region) ?? [] }

    var body: some View {
        List {
            if stories.isEmpty {
                Section {
                    ContentUnavailableView(
                        "Nothing filed yet",
                        systemImage: region.symbolName,
                        description: Text("This desk has no stories in the current edition.")
                    )
                }
            } else {
                ForEach(Array(stories.enumerated()), id: \.element.id) { index, story in
                    Section {
                        NavigationLink(value: story) { StoryRow(story: story) }
                    }
                    if index == 2 {
                        Section {
                            AdSlotView(slot: .mediumRectangle)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(region.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RegionsView().environmentObject(EditionStore.preview)
}
