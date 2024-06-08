// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "WebService",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .tvOS(.v16), .macOS(.v12), .watchOS(.v9), .macCatalyst(.v16), .visionOS(.v1)],
    products: [
        .library(name: "WebService", targets: ["WebService"]),
        .library(name: "WebServiceURLMock", targets: ["WebServiceURLMock"])
    ],
    dependencies: [
        .package(url: "https://github.com/wmalloc/HTTPRequestable.git", from: "0.7.2")
    ],
    targets: [
        .target(name: "WebService", dependencies: ["HTTPRequestable"], swiftSettings: []),
        .target(name: "WebServiceURLMock", dependencies: ["WebService"]),
        .testTarget(name: "WebServiceTests", dependencies: ["HTTPRequestable", "WebService", "WebServiceURLMock"],
                    resources: [.copy("TestData")])
    ]
)
