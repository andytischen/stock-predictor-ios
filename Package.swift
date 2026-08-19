// swift-tools-version:5.9
import PackageDescription

// The platform-agnostic cores of the two apps in this repo: GapModelKit (the
// Codable snapshot models for the gap model) and GlobalNewsKit (the edition
// models behind Randy's Global News First). Both are Foundation only, so they
// build and test on Linux, which is what CI runs. The SwiftUI apps under App/
// and NewsApp/ depend on them but are built with Xcode (see project.yml).
let package = Package(
    name: "GapModelKit",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "GapModelKit", targets: ["GapModelKit"]),
        .library(name: "GlobalNewsKit", targets: ["GlobalNewsKit"]),
    ],
    targets: [
        .target(name: "GapModelKit"),
        .target(name: "GlobalNewsKit"),
        .testTarget(
            name: "GapModelKitTests",
            dependencies: ["GapModelKit"],
            resources: [.process("Fixtures")]
        ),
        .testTarget(
            name: "GlobalNewsKitTests",
            dependencies: ["GlobalNewsKit"],
            resources: [.process("Fixtures")]
        ),
    ]
)
