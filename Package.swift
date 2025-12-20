// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "8.1.1"

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
      checksum: "01842624e962e9c1cacef9678db0cf2bad2affe355b84ab6052b6f43252d1340"
    )
  ]
)
