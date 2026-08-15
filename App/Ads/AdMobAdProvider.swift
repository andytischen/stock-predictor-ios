import SwiftUI

/// Ad unit IDs. These are Google's public test units, which always return a
/// test creative; swap in the real units before shipping.
enum AdMobUnit {
    static let banner = "ca-app-pub-3940256099942544/2435281174"
    static let mediumRectangle = "ca-app-pub-3940256099942544/2435281174"

    static func id(for slot: AdSlot) -> String {
        switch slot {
        case .banner: return banner
        case .mediumRectangle: return mediumRectangle
        }
    }
}

#if canImport(GoogleMobileAds)
import GoogleMobileAds

/// Fills slots with AdMob banners. Each render site gets its own `BannerView`
/// (see `AdProvider`); the SDK, started once here, is the shared state.
final class AdMobAdProvider: AdProvider {
    init() {
        MobileAds.shared.start()
    }

    func adView(for slot: AdSlot) -> AnyView? {
        AnyView(AdMobBanner(slot: slot))
    }
}

private struct AdMobBanner: UIViewRepresentable {
    let slot: AdSlot

    func makeUIView(context: Context) -> BannerView {
        let view = BannerView(adSize: adSize)
        view.adUnitID = AdMobUnit.id(for: slot)
        view.load(Request())
        return view
    }

    func updateUIView(_ view: BannerView, context: Context) {}

    private var adSize: AdSize {
        switch slot {
        case .banner: return AdSizeBanner
        case .mediumRectangle: return AdSizeMediumRectangle
        }
    }
}
#endif
