// swift-tools-version: 5.9.1
import PackageDescription

let package = Package(
    name: "ServerlessSwift",
    products: [
        .executable(name: "ServerlessSwift", targets: ["ServerlessSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/vapor-community/vapor-aws-lambda-runtime", .upToNextMajor(from: "0.4.0"))
    ],
    targets: [
        .executableTarget(
            name: "ServerlessSwift", 
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "VaporAWSLambdaRuntime", package: "vapor-aws-lambda-runtime")
            ],
            path: ".",
            exclude: ["Makefile", "template.yaml", "sam-launch.sh"]
        ),
    ]
)