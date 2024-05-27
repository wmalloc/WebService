// swift-tools-version:5.9

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
        .package(url: "https://github.com/wmalloc/HTTPRequestable.git", from: "0.7.2"),
    ],
    targets: [
        .target(name: "WebService", dependencies: ["HTTPRequestable"], swiftSettings: []),
        .target(name: "WebServiceURLMock", dependencies: ["WebService"]),
        .testTarget(name: "WebServiceTests", dependencies: ["HTTPRequestable", "WebService", "WebServiceURLMock"],
                    resources: [.copy("TestData")]),
    ]
)
