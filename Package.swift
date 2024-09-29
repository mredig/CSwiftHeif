// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSwiftHeif",
	platforms: [
		.macOS(.v13),
	],
    products: [
        .library(
            name: "CSwiftHeif",
            targets: ["CSwiftHeif"]),
    ],
	dependencies: [
		.package(url: "https://github.com/mredig/SwiftPizzaSnips.git", .upToNextMinor(from: "0.4.0")),
		.package(url: "https://github.com/mredig/TinySwiftJPEG.git", .upToNextMajor(from: "0.1.1")),

	],
    targets: [
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
				"TinySwiftJPEG"
			]),
		.testTarget(
			name: "CSwiftHeifTests",
			dependencies: [
				"CSwiftHeif",
				"SwiftPizzaSnips",
				"ResourceVendor",
			]),
		.executableTarget(
			name: "PerformanceTester",
			dependencies: [
				"CSwiftHeif",
				"ResourceVendor",
			]),
		.target(
			name: "ResourceVendor",
			resources: [
				.process("Resources")
			]),
	]
)
