import GapModelKit
import SwiftUI

struct MarketsListView: View {
    @EnvironmentObject private var store: SnapshotStore

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Open calls")
                .refreshable { await store.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch store.state {
        case .idle, .loading:
            ProgressView("Loading…")
        case let .failed(message):
            if #available(iOS 17.0, *) {
                ContentUnavailableView("Couldn't load", systemImage: "wifi.slash", description: Text(message))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash").font(.largeTitle).foregroundStyle(.secondary)
                    Text("Couldn't load").font(.title2.bold())
                    Text(message).font(.callout).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        case let .loaded(snapshot):
            List {
                Section {
                    Text(snapshot.summary).font(.callout).foregroundStyle(.secondary)
                }
                ForEach(Array(regions(in: snapshot).enumerated()), id: \.element) { index, region in
                    Section(region) {
                        ForEach(snapshot.markets.filter { $0.region == region }) { market in
                            NavigationLink(value: market) {
                                MarketRow(market: market)
                            }
                        }
                    }
                    if index == 0 {
                        Section {
                            AdSlotView(slot: .mediumRectangle)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationDestination(for: Market.self) { MarketDetailView(market: $0) }
        }
    }

    private func regions(in snapshot: Snapshot) -> [String] {
        var seen: [String] = []
        for market in snapshot.markets where !seen.contains(market.region) {
            seen.append(market.region)
        }
        return seen
    }
}

private struct MarketRow: View {
    let market: Market

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(market.market).font(.body)
                Text(market.symbol).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(Format.percent(market.pOpenUp))
                    .font(.headline)
                    .foregroundStyle(Format.leansUp(market.pOpenUp) ? .green : .red)
                Text("AUC \(String(format: "%.2f", market.oosAuc))")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}
