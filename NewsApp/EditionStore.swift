import Foundation
import GlobalNewsKit

/// Where the published edition lives. Point this at whatever host serves the
/// newsroom's `news.json`.
enum NewsConfig {
    static let editionURL = URL(
        string: "https://andytischen.github.io/randy-bets/news.json"
    )!
}

/// Observable state for the app: the current edition, load status and the
/// stories the reader has bookmarked.
@MainActor
final class EditionStore: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded(Edition)
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var savedStoryIDs: Set<String> = []

    private let client: EditionClient

    init(client: EditionClient = EditionClient(url: NewsConfig.editionURL)) {
        self.client = client
    }

    private init(edition: Edition) {
        client = EditionClient(url: NewsConfig.editionURL)
        state = .loaded(edition)
    }

    var edition: Edition? {
        if case let .loaded(edition) = state { return edition }
        return nil
    }

    var savedStories: [Story] {
        (edition?.stories ?? []).filter { savedStoryIDs.contains($0.id) }
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await client.fetch())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func isSaved(_ story: Story) -> Bool { savedStoryIDs.contains(story.id) }

    func toggleSaved(_ story: Story) {
        if savedStoryIDs.contains(story.id) {
            savedStoryIDs.remove(story.id)
        } else {
            savedStoryIDs.insert(story.id)
        }
    }

    /// A store already holding the bundled sample edition, so the layout can be
    /// laid out in Xcode previews without the network.
    static var preview: EditionStore {
        guard let url = Bundle.main.url(forResource: "news", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let edition = try? EditionClient.decode(data)
        else { return EditionStore() }
        return EditionStore(edition: edition)
    }
}
