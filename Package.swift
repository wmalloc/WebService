// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebService",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "WebService", targets: ["WebService"]),
        .library(name: "WebServiceCombine", targets: ["WebServiceCombine"]),
        .library(name: "WebServiceConcurrency", targets: ["WebServiceConcurrency"]),
   ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "WebService", dependencies: [], path: "Sources/Core"),
        .target(name: "WebServiceCombine", dependencies: ["WebService"], path: "Sources/Combine"),
        .target(name: "WebServiceConcurrency", dependencies: ["WebService"], path: "Sources/Concurrency"),
        .testTarget(
            name: "WebServiceTests",
            dependencies: ["WebService", "WebServiceCombine", "WebServiceConcurrency"],
            path: "Tests/WebServiceTests"),
    ]
)
