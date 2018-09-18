//
//  FunctionalDataTests.swift
//  FunctionalTableDataTests
//
//  Created by Raul Riera on 2017-10-19.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import FunctionalTableData

class FunctionalDataTests: XCTestCase {
	func testKeyPathFromRowKey() {
		let tableData = FunctionalTableData()
		let tableView = UITableView()
		
		tableData.tableView = tableView
		
		let expectation1 = expectation(description: "first append")
		let cellConfigC1 = TestCaseCell(key: "color1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let cellConfigC2 = TestCaseCell(key: "red2", state: TestCaseState(data: "green"), cellUpdater: TestCaseState.updateView)
		let sectionC1 = TableSection(key: "colors Section", rows: [cellConfigC1, cellConfigC2])
		
		let cellConfigS1 = TestCaseCell(key: "size1", state: TestCaseState(data: "medium"), cellUpdater: TestCaseState.updateView)
		let cellConfigS2 = TestCaseCell(key: "size2", state: TestCaseState(data: "large"), cellUpdater: TestCaseState.updateView)
		let sectionS1 = TableSection(key: "sizes Section", rows: [cellConfigS1, cellConfigS2])
		
		tableData.renderAndDiff([sectionC1, sectionS1]) { [weak tableData] in
			expectation1.fulfill()
			
			if let tableData = tableData, let keyPath = tableData.keyPathForRowKey("size1") {
				XCTAssertTrue(keyPath.sectionKey == "sizes Section" && keyPath.rowKey == "size1")
			} else {
				XCTFail()
			}
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRetrievingIndexPathFromInvalidKeyPath() {
		let tableData = FunctionalTableData()
		let tableView = UITableView()
		
		tableData.tableView = tableView
		let expectation1 = expectation(description: "first append")
		let cellConfigC1 = TestCaseCell(key: "red1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let sectionC1 = TableSection(key: "colors Section", rows: [cellConfigC1])
		tableData.renderAndDiff([sectionC1]) {
			expectation1.fulfill()
		}
		waitForExpectations(timeout: 1, handler: nil)
		
		XCTAssertNil(tableData.indexPathFromKeyPath(FunctionalTableData.KeyPath(sectionKey: "Invalid Section", rowKey: "red1")))
		XCTAssertNil(tableData.indexPathFromKeyPath(FunctionalTableData.KeyPath(sectionKey: "colors Section", rowKey: "Invalid Row")))
	}
	
	func testRetrievingIndexPathFromValidKeyPath() {
		let tableData = FunctionalTableData()
		let tableView = UITableView()
		
		tableData.tableView = tableView
		let expectation1 = expectation(description: "first append")
		let cellConfigC1 = TestCaseCell(key: "red1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let sectionC1 = TableSection(key: "colors Section", rows: [cellConfigC1])
		
		tableData.renderAndDiff([sectionC1]) {
			expectation1.fulfill()
		}
		waitForExpectations(timeout: 1, handler: nil)
		
		let indexPath = tableData.indexPathFromKeyPath(FunctionalTableData.KeyPath(sectionKey: "colors Section", rowKey: "red1"))
		XCTAssertNotNil(indexPath)
	}
	
	func testCellAccessibilityIdentifiers() {
		let tableData = FunctionalTableData()
		let tableView = UITableView()
		
		tableData.tableView = tableView
		let expectation1 = expectation(description: "rendered")
		let cellConfig = TestCaseCell(key: "cellKey", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let section = TableSection(key: "sectionKey", rows: [cellConfig])
		
		tableData.renderAndDiff([section]) {
			expectation1.fulfill()
		}
		waitForExpectations(timeout: 1, handler: nil)
		
		let cell = tableData.tableView?.visibleCells.first
		XCTAssertEqual(cell?.accessibilityIdentifier, "sectionKeycellKey")
	}
	
	func testPerformance() {
		let functionalData = FunctionalTableData()
		
		var oldSections: [TableSection] = []
		for i in 0..<10 {
			oldSections.append(
				TableSection(
					key: "section\(i)",
					rows: (0..<10_000).map {
						TestCaseCell(key: "size\($0)", state: TestCaseState(data: "data-\(i)"), cellUpdater: TestCaseState.updateView)
					}
				)
			)
		}
		let newSections: [TableSection] = oldSections
		
		measure {
			_ = functionalData.calculateTableChanges(oldSections: oldSections, newSections: newSections, visibleIndexPaths: [])
		}
	}
}

typealias TestCaseCell = HostCell<UIView, TestCaseState, LayoutMarginsTableItemLayout>

struct TestCaseState: Equatable {
	var data: String
	
	static func ==(lhs: TestCaseState, rhs: TestCaseState) -> Bool {
		return lhs.data == rhs.data
	}
	
	public static func updateView(_ view: UIView, state: TestCaseState?) -> Void {}
}
