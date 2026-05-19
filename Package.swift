// swift-tools-version:6.3.2

import PackageDescription

let package = Package(
    name: "SwiftRPC",
    products: [
        .library(name: "SwiftRPC", targets: ["SwiftRPC"])
    ],
    dependencies: [
        // https://github.com/Kitura/BlueSocket
        .package(url: "https://github.com/Kitura/BlueSocket", from: "2.0.4")
    ],
    targets: [
        .target(
            name: "SwiftRPC",
            dependencies: [
                .product(name: "Socket", package: "bluesocket")
            ]
        )
    ]
)
