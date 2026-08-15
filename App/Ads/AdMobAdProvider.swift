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
    private let startup = SDKStartup()

    func adView(for slot: AdSlot) -> AnyView? {
        AnyView(AdMobBanner(slot: slot, startup: startup))
    }
}

/// Starts the SDK once, on the launch path as Google documents, and holds back
/// requests until initialization reports done: `start()` returns before that,
/// and mediation adapters only take part in requests made afterwards.
private final class SDKStartup {
    private var isReady = false
    private var pending: [() -> Void] = []

    init() {
        MobileAds.shared.start { [weak self] _ in
            DispatchQueue.main.async { self?.markReady() }
        }
    }

    /// Main thread only, matching the SwiftUI/UIKit callers.
    func whenReady(_ request: @escaping () -> Void) {
        if isReady {
            request()
        } else {
            pending.append(request)
        }
    }

    private func markReady() {
        isReady = true
        let queued = pending
        pending = []
        queued.forEach { $0() }
    }
}

/// A controller rather than a plain view: the SDK needs a `rootViewController`
/// to request an ad and to present the creative's landing page.
private struct AdMobBanner: UIViewControllerRepresentable {
    let slot: AdSlot
    let startup: SDKStartup

    func makeUIViewController(context: Context) -> BannerHost {
        BannerHost(slot: slot, startup: startup)
    }

    func updateUIViewController(_ host: BannerHost, context: Context) {
        host.reload(for: slot)
    }
}

private final class BannerHost: UIViewController {
    private let banner: BannerView
    private let startup: SDKStartup
    private var slot: AdSlot

    init(slot: AdSlot, startup: SDKStartup) {
        self.slot = slot
        self.startup = startup
        banner = BannerView(adSize: Self.adSize(for: slot))
        super.init(nibName: nil, bundle: nil)
        banner.adUnitID = AdMobUnit.id(for: slot)
    }

    /// Re-requests only when the host is reused for a different slot, so an
    /// ordinary SwiftUI update never costs an extra ad request.
    func reload(for slot: AdSlot) {
        guard slot != self.slot else { return }
        self.slot = slot
        banner.adSize = Self.adSize(for: slot)
        banner.adUnitID = AdMobUnit.id(for: slot)
        load()
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
        load()
    }

    private func load() {
        startup.whenReady { [weak self] in
            self?.banner.load(Request())
        }
    }

    private static func adSize(for slot: AdSlot) -> AdSize {
        switch slot {
        case .banner: return AdSizeBanner
        case .mediumRectangle: return AdSizeMediumRectangle
        }
    }
}
#endif
