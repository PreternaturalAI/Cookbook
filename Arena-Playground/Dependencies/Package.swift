// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dependencies",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Dependencies",
            targets: ["Dependencies"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Dependencies"),
        .testTarget(
            name: "DependenciesTests",
            dependencies: ["Dependencies"]),
    ]
)

package.dependencies = [
    .package(url: "https://github.com/PreternaturalAI/Cataphyl", branch: "main"),
    .package(url: "https://github.com/vmanot/BrowserKit", branch: "main"),
    .package(url: "https://github.com/vmanot/OpenAI", branch: "main"),
]
package.targets = [
    .target(name: "Dependencies",
        dependencies: [
            .product(name: "Cataphyl", package: "Cataphyl"),
            .product(name: "BrowserKit", package: "BrowserKit"),
            .product(name: "OpenAI", package: "OpenAI"),
        ]
    )
]
package.platforms = [
    .iOS("16.0"),
    .macOS("13.0"),
    .tvOS("16.0"),
    .watchOS("9.0")
]
