// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "PeakCoreData",
    platforms: [.iOS(.v15),
                .macOS(.v14)],
    products: [
        .library(
            name: "PeakCoreData",
            targets: ["PeakCoreData"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Velociti-Solutions/PeakOperation.git",
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
