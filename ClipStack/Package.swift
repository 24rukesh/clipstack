// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClipStack",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "ClipStack",
            targets: ["ClipStack"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ClipStack",
            path: "Sources/ClipStack",
            exclude: ["Info.plist"],
            resources: [
                .copy("ClipStackDataModel.xcdatamodeld")
            ]
        ),
        .testTarget(
            name: "ClipStackTests",
            dependencies: ["ClipStack"],
            path: "Tests"
        )
    ]
)