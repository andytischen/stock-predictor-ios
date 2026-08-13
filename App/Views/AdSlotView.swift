import SwiftUI

/// Where an advert can be placed. The size matches the standard IAB unit the
/// slot is expected to serve, so layout is stable before any SDK is wired in.
enum AdSlot {
    case banner
    case mediumRectangle

    var height: CGFloat {
        switch self {
        case .banner: return 50
        case .mediumRectangle: return 250
        }
    }

    var label: String {
        switch self {
        case .banner: return "Banner 320×50"
        case .mediumRectangle: return "Medium rectangle 300×250"
        }
    }
}

/// Reserved space for an advert. Renders a labelled placeholder until an ad
/// SDK provides a view through `AdProvider`.
struct AdSlotView: View {
    let slot: AdSlot

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                .foregroundStyle(.secondary)
            VStack(spacing: 2) {
                Text("Advertisement").font(.caption2).bold()
                Text(slot.label).font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: slot.height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Advertisement space")
    }
}
