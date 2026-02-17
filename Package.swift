// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "ManualS",
  products: [
    .library(name: "ManualSClient", targets: ["ManualSClient"]),
    .library(name: "ManualSModels", targets: ["ManualSModels"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
  ],
  targets: [
    .target(
      name: "ManualSModels",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged")
      ],
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
      name: "ManualSTests",
      dependencies: ["ManualSModels"]
    ),
  ]
)
