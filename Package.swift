// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebService",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: "WebService", targets: ["WebService"]),
        .library(name: "WebServiceCombine", targets: ["WebServiceCombine"]),
        .library(name: "WebServiceConcurrency", targets: ["WebServiceConcurrency"]),
        .library(name: "WebServiceURLMock", targets: ["WebServiceURLMock"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wmalloc/URLRequestable.git", from: "0.5.1"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0")
    ],
    targets: [
        .target(name: "WebService", dependencies: ["URLRequestable"], path: "Sources/Core",
                plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]),
        .target(name: "WebServiceCombine", dependencies: ["WebService", "URLRequestable"], path: "Sources/Combine",
                plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]),
        .target(name: "WebServiceConcurrency", dependencies: ["WebService", "URLRequestable"], path: "Sources/Concurrency",
                plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]),
        .target(name: "WebServiceURLMock", dependencies: ["WebService"], path: "Sources/URLMock",
               plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]),
        .testTarget(
            name: "WebServiceTests",
            dependencies: ["URLRequestable", "WebService", "WebServiceCombine", "WebServiceConcurrency", "WebServiceURLMock"],
            path: "Tests/WebServiceTests",
            resources: [.copy("TestData")]
        ),
    ]
)
