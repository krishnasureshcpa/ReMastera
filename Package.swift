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
        .executable(name: "ReMasteraCLI", targets: ["ReMasteraCLI"]),
        .executable(name: "ReMasteraTests", targets: ["ReMasteraTests"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.12.0"),
        .package(url: "https://github.com/rive-app/rive-ios", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "ReMasteraCore",
            dependencies: [
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXRandom", package: "mlx-swift"),
                .product(name: "MLXNN", package: "mlx-swift"),
                .product(name: "MLXOptimizers", package: "mlx-swift"),
                .product(name: "RiveRuntime", package: "rive-ios")
            ],
            path: "Sources/ReMastera"
        ),
        .executableTarget(
            name: "ReMastera",
            dependencies: ["ReMasteraCore"],
            path: "Sources/AppMain"
        ),
        .executableTarget(
            name: "ReMasteraCLI",
            dependencies: [
                "ReMasteraCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/ReMasteraCLI"
        ),
        .executableTarget(
            name: "ReMasteraTests",
            dependencies: ["ReMasteraCore"],
            path: "Tests/ReMasteraTests"
        )
    ]
)
