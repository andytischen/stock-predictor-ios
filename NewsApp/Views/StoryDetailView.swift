import GlobalNewsKit
import SwiftUI

/// The article page: art, kicker, headline, standfirst, byline, body copy with
/// an advert break, and a link out to the full piece.
struct StoryDetailView: View {
    @EnvironmentObject private var store: EditionStore
    let story: Story

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                StoryArtwork(url: story.imageURL, aspectRatio: 16 / 9)
                if story.isBreaking {
                    BreakingFlag()
                }
                StoryKicker(story: story)
                Text(story.headline)
                    .font(.title.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                if !story.standfirst.isEmpty {
                    Text(story.standfirst)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text("\(NewsFormat.byline(story)) · \(NewsFormat.readingTime(story))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Divider()
                paragraphs(of: story)
                if let url = story.articleURL {
                    Link(destination: url) {
                        Label("Read the full story", systemImage: "arrow.up.right.square")
                    }
                    .font(.callout.weight(.medium))
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle(story.region.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleSaved(story)
                } label: {
                    Label(
                        store.isSaved(story) ? "Remove from saved" : "Save story",
                        systemImage: store.isSaved(story) ? "bookmark.fill" : "bookmark"
                    )
                }
            }
        }
    }

    /// Body paragraphs with the advert break dropped in after the opening one,
    /// which is where a news app normally takes its in-article unit.
    @ViewBuilder
    private func paragraphs(of story: Story) -> some View {
        ForEach(Array(story.paragraphs.enumerated()), id: \.offset) { index, paragraph in
            Text(paragraph)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            if index == 0 {
                AdSlotView(slot: .mediumRectangle)
                    .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    NavigationStack {
        StoryDetailView(story: Story(
            id: "sample",
            headline: "OPEC+ signals a quota rethink as Brent slips below $70",
            standfirst: "Delegates say the group is weighing a slower unwind of cuts.",
            body: "First paragraph of the story.\n\nSecond paragraph of the story.",
            region: .middleEast, topic: .energy, source: "Randy's Energy Desk",
            publishedAt: "2026-08-19T05:41:00Z", isBreaking: true
        ))
    }
    .environmentObject(EditionStore.preview)
}
