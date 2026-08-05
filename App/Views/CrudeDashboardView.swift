import GapModelKit
import SwiftUI

struct CrudeDashboardView: View {
    @EnvironmentObject private var store: SnapshotStore

    var body: some View {
        NavigationStack {
            Group {
                if let snapshot = store.snapshot {
                    List {
                        Section("Summary") {
                            Text(snapshot.summary).font(.callout)
                        }
                        Section("Crude") {
                            ForEach(snapshot.crude) { crude in
                                CrudeRow(crude: crude)
                            }
                        }
                    }
                } else {
                    ProgressView("Loading…")
                }
            }
            .navigationTitle("Crude")
            .refreshable { await store.load() }
        }
    }
}

private struct CrudeRow: View {
    let crude: Crude

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(crude.name).font(.body)
                if crude.isShock {
                    Text("SHOCK").font(.caption2).bold().foregroundStyle(.red)
                }
                Spacer()
                Text(String(format: "%.2f", crude.close)).monospacedDigit()
            }
            HStack(spacing: 12) {
                metric("1d", crude.return1d)
                metric("5d", crude.return5d)
                Text("vol20 \(Format.percent(crude.volatility20d))")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func metric(_ label: String, _ value: Double) -> some View {
        Text("\(label) \(Format.signedPercent(value))")
            .font(.caption)
            .foregroundStyle(value >= 0 ? .green : .red)
    }
}
