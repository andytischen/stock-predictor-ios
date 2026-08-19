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
    /// The edition on screen: the last one that loaded, so a failed refresh
    /// leaves the reader on the previous edition rather than an empty app.
    @Published private(set) var edition: Edition?
    /// The stories the reader bookmarked, kept by value so the reading list
    /// survives a failed refresh and stories dropped from a newer edition.
    @Published private(set) var savedStories: [Story] = []

    private let client: EditionClient

    init(client: EditionClient = EditionClient(url: NewsConfig.editionURL)) {
        self.client = client
    }

    private init(edition: Edition) {
        client = EditionClient(url: NewsConfig.editionURL)
        self.edition = edition
        state = .loaded(edition)
    }

    /// Why the last load failed, if it did.
    var loadFailure: String? {
        if case let .failed(message) = state { return message }
        return nil
    }

    func load() async {
        state = .loading
        do {
            let edition = try await client.fetch()
            self.edition = edition
            state = .loaded(edition)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func isSaved(_ story: Story) -> Bool { savedStories.contains { $0.id == story.id } }

    func toggleSaved(_ story: Story) {
        if let index = savedStories.firstIndex(where: { $0.id == story.id }) {
            savedStories.remove(at: index)
        } else {
            savedStories.append(story)
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
