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
            url: "https://dist.acrobits.net/saas/sipis-provider-swift-package/release/SipisProvider.xcframework-171985.zip",
            checksum: "f3d2973c672ff8b4cbdda542e2564618f0d84f48b4207baa4967fcfa48c674b3"),
    ]
)
