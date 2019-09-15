// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "FunctionalTableData",
	platforms: [
		.iOS(.v9)
	],
	products: [
		.library(name: "FunctionalTableData", targets: [
			"FunctionalTableData",
			"FunctionalTableDataTests"
		]),
	],
	targets: [
		.target(name: "FunctionalTableData", path: "FunctionalTableData"),
		.testTarget(name: "FunctionalTableDataTests", dependencies: ["FunctionalTableData"], path: "FunctionalTableDataTests")
	]
)
