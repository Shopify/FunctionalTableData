//
//  TableCellReuseTests.swift
//  FunctionalTableDataTests
//
//  Created by Alun Bestor on 2018-08-21.
//  Copyright © 2018 Shopify. All rights reserved.
//

import XCTest
import Foundation
@testable import FunctionalTableData

class TableCellReuseTests: XCTestCase {
	private typealias LabelCell = HostCell<UILabel, String, LayoutMarginsTableItemLayout>
	
	private var window: WindowWithTableViewMounted!
	private var tableModel: FunctionalTableData!
	
	override func setUp() {
		super.setUp()
		window = WindowWithTableViewMounted()
		tableModel = FunctionalTableData()
		tableModel.tableView = window.tableView
	}
	
	override func tearDown() {
		window.tearDownWindow()
		tableModel = nil
		super.tearDown()
	}
	
	// q.v. https://github.com/Shopify/FunctionalTableData/pull/97
	// Test that cells do not inherit leftover styles from a previous cell config
	func testCellStyleClearedOnReuse() throws {
		let disclosureCell = mockCell(key: "cell", style: CellStyle(highlight: true, accessoryType: .disclosureIndicator))
		let unstyledCell = mockCell(key: "cell", style: nil)
		
		var originalCellView: UITableViewCell?
		
		let renderedDisclosureCell = expectation(description: "Finished rendering disclosure cell")
		tableModel.renderAndDiff([TableSection(key: "section", rows: [disclosureCell])], animated: false) {
			defer {
				renderedDisclosureCell.fulfill()
			}
			
			guard let cellView = self.window.tableView.visibleCells.first else {
				XCTFail("Tableview has no cell views")
				return
			}
			
			XCTAssertEqual(cellView.accessoryType, .disclosureIndicator)
			XCTAssertEqual(cellView.selectionStyle, .default)
			
			// Keep a reference to check that the same cell view is reused for the new state
			originalCellView = cellView
		}
		
		wait(for: [renderedDisclosureCell], timeout: 10.0)
		
		let renderedUnstyledCell = expectation(description: "Finished rendering unstyled cell")
		tableModel.renderAndDiff([TableSection(key: "section", rows: [unstyledCell])], animated: false) {
			defer {
				renderedUnstyledCell.fulfill()
			}
			
			guard let cellView = self.window.tableView.visibleCells.first else {
				XCTFail("Tableview has no cell views")
				return
			}
			
			XCTAssertEqual(cellView, originalCellView, "Original cell view was not reused")
			
			XCTAssertEqual(cellView.accessoryType, .none)
			XCTAssertEqual(cellView.selectionStyle, .none)
		}
		
		wait(for: [renderedUnstyledCell], timeout: 10.0)
	}
	
	private func mockCell(key: String, style: CellStyle?) -> CellConfigType {
		return LabelCell(
			key: key,
			style: style,
			state: "",
			cellUpdater: { _, _ in })
	}
}
