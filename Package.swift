// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "JWRefreshControl",
    products: [
        .library(name: "JWRefreshControl", targets: ["JWRefreshControl"]),
    ],
    targets: [
        .target(name: "JWRefreshControl", path: "JWRefreshControl")
    ],
    swiftLanguageVersions: [.v5]
)
