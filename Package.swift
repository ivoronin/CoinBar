// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoinBar",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CoinBar",
            path: "Sources",
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)
