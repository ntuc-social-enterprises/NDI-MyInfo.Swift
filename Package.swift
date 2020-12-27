// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyInfo",
    platforms: [
      .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MyInfo",
            targets: ["MyInfo"]),
    ],
    dependencies: [
      .package(url: "https://github.com/openid/AppAuth-iOS",
               from: "1.4.0"),
      .package(url: "https://github.com/ntuc-social-enterprises/swift-log",
               from: "1.3.2"),
      .package(url: "https://github.com/auth0/JWTDecode.swift",
               from: "2.5.0"),
      .package(url: "https://github.com/airsidemobile/JOSESwift.git",
               from: "2.3.1"),
      .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git",
               from: "1.3.8"),
      .package(url: "https://github.com/AliSoftware/OHHTTPStubs",
               from: "9.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyInfo",
            dependencies: [
              .product(name: "AppAuth", package: "AppAuth"),
              .product(name: "swift-log", package: "swift-log"),
              .product(name: "JWTDecode", package: "JWTDecode"),
              .product(name: "JOSESwift", package: "JOSESwift"),
              .product(name: "CryptoSwift", package: "CryptoSwift"),
            ]),
        .testTarget(
            name: "MyInfoTests",
            dependencies: [
              "MyInfo",
              .product(name: "OHHTTPStubs", package: "OHHTTPStubs"),
              .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubsSwift"),
            ],
            path: "Test",
            exclude: ["Info.plist"],
            resources: [.copy("Supporting Files/MyInfo.der"),
                        .copy("Supporting Files/MyInfo.p12"),
                        .copy("Supporting Files/MyInfo.plist"),
            ]),
    ]
)
