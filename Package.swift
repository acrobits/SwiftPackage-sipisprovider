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
            checksum: "a9fb1984684b7f54b56cde4bfb52f293f3c3b3a3b39623a32016bdc790dd780d"),
    ]
)
