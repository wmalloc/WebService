// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "WebService",
  defaultLocalization: "en",
  platforms: [.iOS(.v16), .tvOS(.v16), .macOS(.v12), .watchOS(.v9), .macCatalyst(.v16), .visionOS(.v1)],
  products: [
    .library(name: "WebService", targets: ["WebService"])
  ],
  dependencies: [
    .package(url: "https://github.com/wmalloc/HTTPRequestable.git", from: "0.10.0")
  ],
  targets: [
    .target(name: "WebService", dependencies: ["HTTPRequestable"], swiftSettings: []),
    .testTarget(name: "WebServiceTests", dependencies: ["HTTPRequestable", "WebService",
                                                        .product(name: "MockURLProtocol", package: "HTTPRequestable")],
                resources: [.copy("TestData")])
  ]
)
