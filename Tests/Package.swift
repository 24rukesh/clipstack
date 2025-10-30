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
        .testTarget(
            name: "ClipStackTests",
            dependencies: [],
            path: "."
        )
    ]
)