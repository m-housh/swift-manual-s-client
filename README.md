# swift-manual-s-client

Implements manual-S calculations for HVAC equipment selection. Based on 2014 edition.

## Usage

Include in your swift project.

```swift
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/m-housh/swift-manual-s-client.git", from: "0.1.0")
  ],
  targets: [
    .target(
      name: "MyTarget",
      dependencies: [
        .package(name: "ManualSClient", package: "swift-manual-s-client"),
      ],
    ),
    ...
  ]
)
```
