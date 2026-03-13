// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "ManualS",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .executable(name: "server", targets: ["server"]),
    .library(name: "ManualSClient", targets: ["ManualSClient"]),
    .library(name: "ManualSDatabase", targets: ["ManualSDatabase"]),
    .library(name: "ManualSModels", targets: ["ManualSModels"]),
    .library(name: "ManualSRouter", targets: ["ManualSRouter"]),
    .library(name: "ManualSViewController", targets: ["ManualSViewController"]),
  ],
  dependencies: [
    // FIX: Use tagged version
    .package(url: "https://github.com/m-housh/swift-shared-manuals.git", branch: "main"),
    .package(url: "https://github.com/m-housh/swift-validations.git", from: "0.3.6"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.2"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
  ],
  targets: [
    .executableTarget(
      name: "server",
      dependencies: [
        .target(name: "ManualSViewController"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        .product(name: "SharedMiddleware", package: "swift-shared-manuals"),
        .product(name: "Vapor", package: "vapor"),
      ]
    ),
    .target(
      name: "ManualSModels",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "SharedModels", package: "swift-shared-manuals"),
        .product(name: "Validations", package: "swift-validations"),
      ],
    ),
    .testTarget(
      name: "ManualSModelTests",
      dependencies: [
        .target(name: "ManualSModels")
      ]
    ),
    .target(
      name: "ManualSClient",
      dependencies: [
        .target(name: "ManualSModels"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ],
    ),
    .testTarget(
      name: "ManualSClientTests",
      dependencies: ["ManualSClient"]
    ),
    .target(
      name: "ManualSDatabase",
      dependencies: [
        .target(name: "ManualSModels"),
        .product(name: "SharedDatabase", package: "swift-shared-manuals"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ],
    ),
    .testTarget(
      name: "ManualSDatabaseTests",
      dependencies: [
        .target(name: "ManualSDatabase"),
        .product(name: "SharedTestSupport", package: "swift-shared-manuals"),
      ]
    ),
    .target(
      name: "ManualSRouter",
      dependencies: [
        .target(name: "ManualSModels"),
        .product(name: "URLRouting", package: "swift-url-routing"),
      ]
    ),
    .testTarget(
      name: "ManualSRouteTests",
      dependencies: [
        .target(name: "ManualSRouter")
      ]
    ),
    .target(
      name: "ManualSViewController",
      dependencies: [
        .target(name: "ManualSDatabase"),
        .target(name: "ManualSRouter"),
        .target(name: "ManualSClient"),
        .product(name: "AuthClient", package: "swift-shared-manuals"),
        .product(name: "SharedMiddleware", package: "swift-shared-manuals"),
        .product(name: "SharedViews", package: "swift-shared-manuals"),
      ],
    ),
  ]
)
