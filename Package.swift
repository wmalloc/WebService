// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebService",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .tvOS(.v15), .macOS(.v11), .watchOS(.v8), .macCatalyst(.v15)],
    products: [
        .library(name: "WebService", targets: ["WebService"]),
        .library(name: "WebServiceURLMock", targets: ["WebServiceURLMock"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wmalloc/URLRequestable.git", from: "0.5.5"),
    ],
    targets: [
        .target(name: "WebService", dependencies: ["URLRequestable"]),
        .target(name: "WebServiceURLMock", dependencies: ["WebService"]),
        .testTarget(name: "WebServiceTests", dependencies: ["URLRequestable", "WebService", "WebServiceURLMock"],
                    resources: [.copy("TestData")]),
    ]
)
