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
            url: "https://dist.acrobits.net/sipisprovider-swift-package/release/SipisProvider.xcframework-183178.zip",
            checksum: "4172f8435da8bcad5032253601a9f5cf8e2c813dc538a3bcc39592cdc1fa1b0d"),
    ]
)
