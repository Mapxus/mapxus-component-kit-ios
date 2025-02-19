// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "7.3.0"

let package = Package(
  name: "MapxusComponentKit",
  platforms: [
    .iOS(.v9),
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
      checksum: "fea9c6628614e9f4a6ad35465b8566db3b979469bcf75eb66a7ab0a2b31baa34"
    )
  ]
)
