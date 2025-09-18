// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacDeviceKey",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Build as a static library (.a)
        .library(
            name: "MacDeviceKey",
            type: .static,        // <- static library
            targets: ["MacDeviceKey"]
        ),
    ],
    targets: [
        .target(
            name: "MacDeviceKey"
        ),
        .testTarget(
            name: "MacDeviceKeyTests",
            dependencies: ["MacDeviceKey"]
        ),
    ]
)

