// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPackage-sipisprovider",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftPackage-sipisprovider",
            targets: ["SipisProvider"]),
    ],
    targets: [
        .binaryTarget(
            name: "SipisProvider",
            url: "https://dist.acrobits.net/saas/sipis-provider-swift-package/release/SipisProvider.xcframework-175238.zip",
            checksum: "879e2d8fd3e3af7e95acdb68bb7b45a5c28e6c9677e858776219c058f70d267d"),
    ]
)
