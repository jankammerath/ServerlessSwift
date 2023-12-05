// swift-tools-version: 5.9.0
import PackageDescription

let package = Package(
    name: "ServerlessSwift",
    platforms: [
        /* intended target is Linux, just dropping this here as
            the Package.swift does not support Linux, yet. */
        .macOS(.v14),
    ],
    products: [
        .executable(name: "ServerlessSwift", targets: ["ServerlessSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.88.0")),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", branch: "main"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "ServerlessSwift", 
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
            ],
            path: ".",
            exclude: [
                "Makefile",
                "template.yaml",
                "sam-launch.sh",
                "bootstrap",
                "bin/bootstrap",
                "LICENSE.txt",
                "samconfig.toml",
                "README.md"
            ]
        ),
    ]
)
