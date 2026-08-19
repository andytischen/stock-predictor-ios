import GlobalNewsKit
import SwiftUI

/// The front page: masthead, the lead story above the fold, a region rail and
/// the rest of the edition, with an advert break after the lead.
struct TopStoriesView: View {
    @EnvironmentObject private var store: EditionStore

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Top stories")
                .navigationDestination(for: Story.self) { StoryDetailView(story: $0) }
                .navigationDestination(for: Region.self) { RegionFeedView(region: $0) }
                .refreshable { await store.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let edition = store.edition {
            List {
                Section {
                    Masthead(edition: edition)
                }
                if let lead = edition.lead {
                    Section {
                        NavigationLink(value: lead) { LeadStoryCard(story: lead) }
                    }
                }
                Section {
                    AdSlotView(slot: .mediumRectangle)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                Section {
                    RegionRail(regions: edition.regions)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                Section("More from the edition") {
                    ForEach(edition.rest) { story in
                        NavigationLink(value: story) { StoryRow(story: story) }
                    }
                }
            }
            .listStyle(.plain)
        } else {
            EditionLoadingView()
        }
    }
}

/// Horizontally scrolling shortcuts into each desk's feed.
private struct RegionRail: View {
    let regions: [Region]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(regions, id: \.self) { region in
                    NavigationLink(value: region) {
                        Label(region.title, systemImage: region.symbolName)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(.quaternary, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    TopStoriesView().environmentObject(EditionStore.preview)
}
