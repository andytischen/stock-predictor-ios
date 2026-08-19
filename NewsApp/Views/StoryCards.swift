import GlobalNewsKit
import SwiftUI

/// The above-the-fold treatment: full-width art, kicker, big headline and the
/// standfirst underneath.
struct LeadStoryCard: View {
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            StoryArtwork(url: story.imageURL, aspectRatio: 16 / 9)
            if story.isBreaking {
                BreakingFlag()
            }
            StoryKicker(story: story)
            Text(story.headline)
                .font(.largeTitle.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
            if !story.standfirst.isEmpty {
                Text(story.standfirst)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(NewsFormat.byline(story))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// The list treatment: headline and byline beside a small square of art.
struct StoryRow: View {
    let story: Story

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                StoryKicker(story: story)
                Text(story.headline)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                Text(NewsFormat.byline(story))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            StoryArtwork(url: story.imageURL, aspectRatio: 1)
                .frame(width: 76)
        }
        .padding(.vertical, 2)
    }
}

/// Topic and region above a headline, the way a newspaper kicker reads.
struct StoryKicker: View {
    let story: Story

    var body: some View {
        Text("\(story.topic.title.uppercased()) · \(story.region.title.uppercased())")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.tint)
    }
}

struct BreakingFlag: View {
    var body: some View {
        Text("BREAKING")
            .font(.caption2.weight(.heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.red, in: RoundedRectangle(cornerRadius: 4))
            .accessibilityLabel("Breaking news")
    }
}

/// Story art with a stable frame, so the layout doesn't jump while the image
/// loads or when a story ships without one.
struct StoryArtwork: View {
    let url: URL?
    let aspectRatio: CGFloat

    var body: some View {
        Rectangle()
            .fill(.quaternary)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                if let url {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .accessibilityHidden(true)
    }
}

/// The masthead that sits above the first story of an edition.
struct Masthead: View {
    let edition: Edition

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("RANDY'S GLOBAL NEWS FIRST")
                .font(.caption.weight(.heavy))
                .tracking(1.5)
            Text(edition.headline)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let generated = edition.generatedDate {
                Text("Edition \(NewsFormat.age(of: generated))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
