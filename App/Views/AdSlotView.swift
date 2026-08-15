import SwiftUI

/// Where an advert can be placed. The size matches the standard IAB unit the
/// slot is expected to serve, so layout is stable however the slot is filled.
enum AdSlot: Hashable {
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

/// Reserved space for an advert, filled by the environment's `AdProvider` and
/// falling back to a labelled placeholder when there is no fill.
struct AdSlotView: View {
    let slot: AdSlot

    @Environment(\.adProvider) private var provider

    var body: some View {
        Group {
            if let ad = provider.adView(for: slot) {
                ad
            } else {
                placeholder
            }
        }
        .frame(maxWidth: slot.width)
        .frame(height: slot.height)
        .frame(maxWidth: .infinity)
    }

    /// Collapsed for VoiceOver: it is empty space, not content. A filled slot
    /// keeps the network's own accessibility tree so its controls stay reachable.
    private var placeholder: some View {
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
