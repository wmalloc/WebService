// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebService",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "WebService", targets: ["WebService"]),
        .library(name: "WebServiceCombine", targets: ["WebServiceCombine"]),
        .library(name: "WebServiceConcurrency", targets: ["WebServiceConcurrency"]),
        .library(name: "WebServiceURLMock", targets: ["WebServiceURLMock"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lukepistrol/SwiftLintPlugin.git", from: "0.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "WebService", dependencies: [], path: "Sources/Core",
                plugins: [.plugin(name: "SwiftLint", package: "SwiftLintPlugin")]),
        .target(name: "WebServiceCombine", dependencies: ["WebService"], path: "Sources/Combine"),
        .target(name: "WebServiceConcurrency", dependencies: ["WebService"], path: "Sources/Concurrency"),
        .target(name: "WebServiceURLMock", dependencies: ["WebService"], path: "Sources/URLMock"),
        .testTarget(
            name: "WebServiceTests",
            dependencies: ["WebService", "WebServiceCombine", "WebServiceConcurrency", "WebServiceURLMock"],
            path: "Tests/WebServiceTests",
            resources: [.copy("TestData")]
        ),
    ]
)
