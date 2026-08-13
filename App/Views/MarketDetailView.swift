import GapModelKit
import SwiftUI

struct MarketDetailView: View {
    let market: Market

    var body: some View {
        List {
            Section("Next open") {
                LabeledContent("Probability up") {
                    Text(Format.percent(market.pOpenUp))
                        .foregroundStyle(Format.leansUp(market.pOpenUp) ? .green : .red)
                }
                LabeledContent("Session", value: market.session)
                if let open = market.sessionOpenDate {
                    LabeledContent("Opens", value: open.formatted(date: .abbreviated, time: .shortened))
                }
                if let shocked = market.pShocked {
                    LabeledContent("Under shock", value: Format.percent(shocked))
                }
            }

            Section("Model quality (out of sample)") {
                LabeledContent("AUC", value: String(format: "%.2f", market.oosAuc))
                LabeledContent("Accuracy", value: String(format: "%.2f", market.oosAccuracy))
                LabeledContent("Brier skill", value: String(format: "%.2f", market.oosBrierSkill))
                LabeledContent("Base rate", value: Format.percent(market.baseRate))
            }

            Section {
                AdSlotView(slot: .mediumRectangle)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section("Top drivers (log-odds)") {
                ForEach(market.drivers) { driver in
                    LabeledContent(driver.name) {
                        Text(String(format: "%+.3f", driver.logOdds))
                            .foregroundStyle(driver.logOdds >= 0 ? .green : .red)
                            .monospacedDigit()
                    }
                }
            }
        }
        .navigationTitle(market.market)
        .navigationBarTitleDisplayMode(.inline)
    }
}
