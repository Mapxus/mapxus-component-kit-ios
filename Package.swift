// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "8.6.0"

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
      checksum: "c6581a2d6163d471f52623b3d94f8c8a34e18cc754698ff22812112e4f3405a6"
    )
  ]
)
