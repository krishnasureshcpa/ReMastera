// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ReMastera",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(name: "ReMasteraCore", targets: ["ReMasteraCore"]),
        .executable(name: "ReMastera", targets: ["ReMastera"]),
        .executable(name: "ReMasteraTests", targets: ["ReMasteraTests"])
    ],
    targets: [
        .target(
            name: "ReMasteraCore",
            path: "Sources/ReMastera"
        ),
        .executableTarget(
            name: "ReMastera",
            dependencies: ["ReMasteraCore"],
            path: "Sources/AppMain"
        ),
        .executableTarget(
            name: "ReMasteraTests",
            dependencies: ["ReMasteraCore"],
            path: "Tests/ReMasteraTests"
        )
    ]
)
