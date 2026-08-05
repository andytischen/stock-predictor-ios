// swift-tools-version:5.9
import PackageDescription

// GapModelKit is the platform-agnostic core: the Codable snapshot models and a
// small client that downloads the published JSON. It builds and tests on Linux
// (Foundation only, no SwiftUI), which is what CI runs. The SwiftUI app under
// App/ depends on this package but is built with Xcode (see project.yml).
let package = Package(
    name: "GapModelKit",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "GapModelKit", targets: ["GapModelKit"]),
    ],
    targets: [
        .target(name: "GapModelKit"),
        .testTarget(
            name: "GapModelKitTests",
            dependencies: ["GapModelKit"],
            resources: [.process("Fixtures")]
        ),
    ]
)
