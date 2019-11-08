// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCLogParser",
    products: [
    	.executable(name: "xclogparser", targets: ["XCLogParserApp"]),
        .library(name: "XCLogParser", targets: ["XCLogParser"])
    ],
    dependencies: [
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.1.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.17.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.0.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name:"XcodeHasher",
            dependencies: ["CryptoSwift"]
        ),
        .target(
            name: "XCLogParser",
            dependencies: ["Gzip", "XcodeHasher", "PathKit"]
        ),
        .target(
            name: "XCLogParserApp",
            dependencies: ["XCLogParser", "Commandant"]
        ),
        .testTarget(
            name: "XCLogParserTests",
            dependencies: ["XCLogParser"]
        ),
    ]

)
