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
            url: "https://dist.acrobits.net/saas/sipis-provider-swift-package/release/SipisProvider.xcframework-173726.zip",
            checksum: "0fd1f2e59eac82b97a98d01d7ac70c7829a6f62215a5504738b27589749ae56a"),
    ]
)
