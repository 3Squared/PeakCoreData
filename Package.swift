// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "PeakCoreData",
    platforms: [.iOS(.v12),
                .macOS(.v14)],
    products: [
        .library(
            name: "PeakCoreData",
            targets: ["PeakCoreData"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/3squared/PeakOperation.git",
            from: "4.0.0"
        )
    ],
    targets: [
        .target(
            name: "PeakCoreData",
            dependencies: ["PeakOperation"]),
        .testTarget(
            name: "PeakCoreDataTests",
            dependencies: ["PeakCoreData"])
    ]
)
