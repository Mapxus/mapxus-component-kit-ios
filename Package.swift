// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "8.7.0"

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
      checksum: "78368de3f7edebcd8b5bb92db774f3f66b1e2b675f3b97707924777dfd7b2cf0"
    )
  ]
)
