// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MZMapKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MZMapKit",
            targets: ["MZMapKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sk-chanch/ClusterKit", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/sk-chanch/mapbox-directions-swift", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution", .upToNextMinor(from: "5.13.0")),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift",from: "7.0.0")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MZMapKit",
            dependencies: [
                .product(name: "ClusterKit", package: "ClusterKit"),
                .product(name: "MapboxDirections", package: "mapbox-directions-swift"),
                .product(name: "Mapbox", package: "maplibre-gl-native-distribution"),
                .product(name: "SwifterSwift", package: "SwifterSwift"),
            ],
            path: "Sources"),
        
    ]
)
