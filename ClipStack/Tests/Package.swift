// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ClipStackTests",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ClipStackTests",
            targets: ["ClipStackTests"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ClipStack",
            path: "../Sources/ClipStack"
        ),
        .testTarget(
            name: "ClipStackTests",
            dependencies: ["ClipStack"],
            path: "."
        )
    ]
)