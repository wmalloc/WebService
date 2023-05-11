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
        .package(url: "https://github.com/wmalloc/URLRequestable.git", .upToNextMajor(from: "0.0.7")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "WebService", dependencies: ["URLRequestable"], path: "Sources/Core"),
        .target(name: "WebServiceCombine", dependencies: ["WebService", "URLRequestable"], path: "Sources/Combine"),
        .target(name: "WebServiceConcurrency", dependencies: ["WebService", "URLRequestable"], path: "Sources/Concurrency"),
        .target(name: "WebServiceURLMock", dependencies: ["WebService"], path: "Sources/URLMock"),
        .testTarget(
            name: "WebServiceTests",
            dependencies: ["URLRequestable", "WebService", "WebServiceCombine", "WebServiceConcurrency", "WebServiceURLMock"],
            path: "Tests/WebServiceTests",
            resources: [.copy("TestData")]
        ),
    ]
)
