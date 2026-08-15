import SwiftUI

/// Ad unit IDs, one per slot. Both are Google's public banner test unit, which
/// serves a test creative at whichever size is requested; the real units differ
/// per slot and must be substituted before shipping.
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

/// A controller rather than a plain view: the SDK needs a `rootViewController`
/// to request an ad and to present the creative's landing page.
private struct AdMobBanner: UIViewControllerRepresentable {
    let slot: AdSlot

    func makeUIViewController(context: Context) -> BannerHost {
        BannerHost(slot: slot)
    }

    func updateUIViewController(_ host: BannerHost, context: Context) {}
}

private final class BannerHost: UIViewController {
    private let banner: BannerView

    init(slot: AdSlot) {
        banner = BannerView(adSize: Self.adSize(for: slot))
        super.init(nibName: nil, bundle: nil)
        banner.adUnitID = AdMobUnit.id(for: slot)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        banner.rootViewController = self
        banner.load(Request())
    }

    private static func adSize(for slot: AdSlot) -> AdSize {
        switch slot {
        case .banner: return AdSizeBanner
        case .mediumRectangle: return AdSizeMediumRectangle
        }
    }
}
#endif
