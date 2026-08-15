import SwiftUI

/// Supplies the creative for a slot. An implementation wraps whichever ad
/// network is linked in; returning `nil` means "no fill", which leaves the
/// reserved space showing its placeholder.
///
/// A slot's view must be created once and retained by the provider: the banner
/// slot is attached to every tab, so returning a fresh view per call would
/// start a new request and impression lifecycle on each tab switch.
protocol AdProvider: AnyObject {
    func adView(for slot: AdSlot) -> AnyView?
}

/// The default: never fills, so every slot renders its labelled placeholder.
/// Used until a network is linked in.
final class PlaceholderAdProvider: AdProvider {
    func adView(for slot: AdSlot) -> AnyView? { nil }
}

/// Fills every slot with an opaque stand-in creative, retaining one view per
/// slot the way a real provider must. For previews and manual layout checks.
final class MockAdProvider: AdProvider {
    private var views: [AdSlot: AnyView] = [:]

    func adView(for slot: AdSlot) -> AnyView? {
        if let view = views[slot] { return view }
        let view = AnyView(MockCreative(slot: slot))
        views[slot] = view
        return view
    }
}

private struct MockCreative: View {
    let slot: AdSlot

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).fill(.tint.opacity(0.15))
            Text("Mock ad · \(slot.label)").font(.caption2).bold()
        }
    }
}

private struct AdProviderKey: EnvironmentKey {
    static let defaultValue: AdProvider = PlaceholderAdProvider()
}

extension EnvironmentValues {
    var adProvider: AdProvider {
        get { self[AdProviderKey.self] }
        set { self[AdProviderKey.self] = newValue }
    }
}
