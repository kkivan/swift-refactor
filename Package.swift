// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-refactor",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(
      name: "swift-refactor",
      targets: ["swift-refactor"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-syntax.git",
      .exact("0.50700.1")),
    .package(
      url: "https://github.com/apple/swift-format.git",
      .exact("0.50700.1")),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "swift-refactor",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(name: "SwiftFormat", package: "swift-format"),
      ]),
    .testTarget(
      name: "swift-refactorTests",
      dependencies: [
        "swift-refactor",
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(name: "SwiftFormat", package: "swift-format"),
      ]),
  ]
)
