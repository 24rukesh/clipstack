// swift-tools-version:5.5
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
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ClipStack",
            dependencies: [],
            path: "Sources",
            exclude: ["Info.plist"],
            resources: [
                .process("ClipStackDataModel.xcdatamodeld")
            ]
        )
    ]
)