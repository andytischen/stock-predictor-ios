import Foundation
import GapModelKit

/// Where the published snapshot lives. Update the host/path to match your
/// GitHub Pages deployment from the Stock-Market-Predictor publish workflow.
enum Config {
    static let snapshotURL = URL(
        string: "https://andytischen.github.io/Stock-Market-Predictor/snapshot.json"
    )!
}

/// Observable state for the app: loads the snapshot and exposes load status.
@MainActor
final class SnapshotStore: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded(Snapshot)
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    private let client: SnapshotClient

    init(client: SnapshotClient = SnapshotClient(url: Config.snapshotURL)) {
        self.client = client
    }

    var snapshot: Snapshot? {
        if case let .loaded(snapshot) = state { return snapshot }
        return nil
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await client.fetch())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
