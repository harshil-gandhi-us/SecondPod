// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SecondNetwork",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SecondNetwork",
            targets: ["SecondNetwork"]
        )
    ],
    targets: [
        .target(
            name: "SecondNetwork",
            path: "Sources/SecondPod"
        ),
        .testTarget(
            name: "SecondNetworkTests",
            dependencies: ["SecondNetwork"],
            path: "Tests/SecondNetworkTests"
        ),
    ]
)
