import SwiftUI

/// Supplies the creative for a slot. An implementation wraps whichever ad
/// network is linked in; returning `nil` means "no fill", which leaves the
/// reserved space showing its placeholder.
///
/// Called from `body`, so it must be cheap and must not mutate state that
/// SwiftUI observes. A slot can be rendered at more than one position in the
/// view tree (the banner is attached to every tab), and SwiftUI instantiates
/// each position separately: an implementation must hand each site its own
/// native view and share only the request/loader state behind it. Handing back
/// one retained UIKit view would reparent it away from the other site.
protocol AdProvider: AnyObject {
    func adView(for slot: AdSlot) -> AnyView?
}

/// The default: never fills, so every slot renders its labelled placeholder.
/// Used until a network is linked in.
final class PlaceholderAdProvider: AdProvider {
    func adView(for slot: AdSlot) -> AnyView? { nil }
}

/// Fills every slot with an opaque stand-in creative. For previews and manual
/// layout checks.
final class MockAdProvider: AdProvider {
    func adView(for slot: AdSlot) -> AnyView? {
        AnyView(MockCreative(slot: slot))
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
