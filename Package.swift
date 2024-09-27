// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSwiftHeif",
	platforms: [
		.macOS(.v13),
	],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CSwiftHeif",
            targets: ["CSwiftHeif"]),
    ],
	dependencies: [
		.package(url: "https://github.com/mredig/SwiftPizzaSnips.git", .upToNextMinor(from: "0.4.0")),
//		.package(url: "https://github.com/twostraws/swiftgd.git", from: "2.5.0"),
		.package(url: "https://github.com/mredig/swiftgd.git", branch: "contrib"),

	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.

		.systemLibrary(
			name: "Clibheif",
			pkgConfig: "libheif",
			providers: [
				.brew(["libheif"]),
				.apt(["libheif-dev"]),
			]),
		.systemLibrary(
			name: "Clibde265",
			pkgConfig: "libde265",
			providers: [
				.brew(["libde265"]),
				.apt(["libde265-dev"]),
			]),
		.target(
			name: "CSwiftHeif",
			dependencies: [
				"Clibheif",
				"Clibde265",
				"SwiftPizzaSnips",
				.product(name: "SwiftGD", package: "swiftgd"),
			]),
		.testTarget(
			name: "CSwiftHeifTests",
			dependencies: [
				"CSwiftHeif",
				"SwiftPizzaSnips",
				"ResourceVendor",
			]),
		.target(
			name: "ResourceVendor",
			resources: [
				.process("Resources")
			]),
	]
)
