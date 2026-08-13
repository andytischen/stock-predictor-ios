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

    var width: CGFloat {
        switch self {
        case .banner: return 320
        case .mediumRectangle: return 300
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
/// SDK fills the slot.
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
        .frame(width: slot.width, height: slot.height)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Advertisement space")
    }
}

extension View {
    /// Pins a banner slot above the tab bar without covering scrolled content.
    func bannerAdSlot() -> some View {
        safeAreaInset(edge: .bottom) {
            AdSlotView(slot: .banner)
                .padding(.vertical, 4)
                .background(.bar)
        }
    }
}
