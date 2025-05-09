// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "7.5.0"

let package = Package(
  name: "MapxusComponentKit",
  platforms: [
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "MapxusComponentKit",
      targets: ["MapxusComponentKit"]),
  ],
  targets: [
    .binaryTarget(
      name: "MapxusComponentKit",
      url: "https://nexus3.mapxus.com/repository/ios-sdk/\(version)/mapxus-component-kit-ios.zip",
      checksum: "c7f250192314ebceba34fa5b2d355cd849eec0e9bd22e1e60a768841fc04f94d"
    )
  ]
)
