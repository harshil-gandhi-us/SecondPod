// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SecondPod",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SecondPod",
            targets: ["SecondPod"]
        )
    ],
    targets: [
        .target(
            name: "SecondPod",
            path: "Sources/SecondPod"
        ),
        .testTarget(
            name: "SecondPodTests",
            dependencies: ["SecondPod"],
            path: "Tests/SecondPodTests"
        ),
    ]
)
