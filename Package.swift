// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "FunctionalTableData",
	platforms: [
		.iOS(.v9)
	],
	products: [
		.library(
			name: "FunctionalTableData",
			targets: [
				"FunctionalTableData"
		]),
	],
	dependencies: [
		.package(url: "https://github.com/mattgallagher/CwlCatchException.git", from: Version("2.0.0-beta.1"))
	],
	targets: [
		.target(
			name: "FunctionalTableData",
			dependencies: [
				"CwlCatchException"
		]),
		.testTarget(
			name: "FunctionalTableDataTests",
			dependencies: [
				"FunctionalTableData"
		]),
	]
)
