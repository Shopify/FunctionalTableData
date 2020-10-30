//
//  CellStyleTests.swift
//  FunctionalTableDataTests
//
//  Created by Kevin Barnes on 2017-10-23.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import FunctionalTableData

class StyleTests: XCTestCase {

	static let indexPath = IndexPath(row: 0, section: 0)
	
	var tableData: FunctionalTableData!
	var tableView: UITableView!
	var cell: TestCaseCell!
	var viewCell: UITableViewCell!

	struct ColoredBackgroundProvider: BackgroundViewProvider {
		let color: UIColor

		public func backgroundView() -> UIView? {
			let bgView = UIView()
			bgView.backgroundColor = color
			return bgView
		}

		public func isEqualTo(_ other: BackgroundViewProvider?) -> Bool {
			guard let other = other as? ColoredBackgroundProvider else { return false }
			return color == other.color
		}
	}
	
	override func setUp() {
		super.setUp()
		cell = TestCaseCell(key: "first", style: CellStyle(), state: TestCaseState(data: "first"), cellUpdater: TestCaseState.updateView)
		tableData = FunctionalTableData()
		tableView = UITableView()
		tableData.tableView = tableView
		applyStyle()
	}
	
	override func tearDown() {
		super.tearDown()
		tableData = nil
		tableView = nil
		cell = nil
		viewCell = nil
	}
	
	func applyStyle() {
		let expectation1 = expectation(description: "applyStyle")
		tableData.renderAndDiff([TableSection(key: "first", rows: [cell])], animated: false) { [weak self] in
			guard let self = self else { return }
			self.viewCell = self.tableView.dataSource?.tableView(self.tableView, cellForRowAt: Self.indexPath)
			self.viewCell.layoutIfNeeded()
			expectation1.fulfill()
		}
		wait(for: [expectation1], timeout: 1000)
	}
	
	func testBottomSeparator() {
		cell.style?.bottomSeparator = .full
		applyStyle()
		var separator = viewCell.viewWithTag(Separator.Tag.bottom.rawValue)
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, viewCell.bounds.width)
		
		cell.style?.bottomSeparator = .inset
		applyStyle()
		separator = viewCell.viewWithTag(Separator.Tag.bottom.rawValue)
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, viewCell.bounds.width - viewCell.layoutMarginsGuide.layoutFrame.minX)
		
		cell.style?.bottomSeparator = nil
		applyStyle()
		separator = viewCell.viewWithTag(Separator.Tag.bottom.rawValue)
		XCTAssertNil(separator)
	}
	
	func testCustomBottomSeparator() {
		cell.style?.bottomSeparator = Separator.Style(leadingInset: .init(value: 10, respectingLayoutMargins: false), trailingInset: .none, thickness: 20)
		applyStyle()
		let separator = viewCell.viewWithTag(Separator.Tag.bottom.rawValue)
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, viewCell.bounds.width - 10)
		XCTAssertEqual(separator!.bounds.height, 20)
	}
	
	func testTopSeparator() {
		cell.style?.topSeparator = .full
		applyStyle()
		var separator = viewCell.viewWithTag(Separator.Tag.top.rawValue)
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, viewCell.bounds.width)
		
		cell.style?.topSeparator = .inset
		applyStyle()
		separator = viewCell.viewWithTag(Separator.Tag.top.rawValue)
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, viewCell.bounds.width - viewCell.layoutMarginsGuide.layoutFrame.minX)
		
		cell.style?.topSeparator = nil
		applyStyle()
		separator = viewCell.viewWithTag(Separator.Tag.top.rawValue)
		XCTAssertNil(separator)
	}
	
	func testCustomTopSeparator() {
		cell.style?.topSeparator = Separator.Style(leadingInset: .init(value: 10, respectingLayoutMargins: false), trailingInset: .none, thickness: 20)
		applyStyle()
		let separator = viewCell.viewWithTag(Separator.Tag.top.rawValue)
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, viewCell.bounds.width - 10)
		XCTAssertEqual(separator!.bounds.height, 20)
	}
	
	func testHighlight() {
		cell.style?.highlight = true
		applyStyle()
		XCTAssertEqual(viewCell.selectionStyle, .default)
		cell.style?.highlight = false
		applyStyle()
		XCTAssertEqual(viewCell.selectionStyle, .none)
		cell.style?.highlight = nil
		applyStyle()
		XCTAssertEqual(viewCell.selectionStyle, .none)
	}
	
	func testAccessoryType() {
		cell.style?.accessoryType = .disclosureIndicator
		applyStyle()
		XCTAssertEqual(viewCell.accessoryType, .disclosureIndicator)
		cell.style?.accessoryType = .checkmark
		applyStyle()
		XCTAssertEqual(viewCell.accessoryType, .checkmark)
		cell.style?.accessoryType = .none
		applyStyle()
		XCTAssertEqual(viewCell.accessoryType, .none)
	}
	
	func testSelectionColor() {
		cell.style?.selectionColor = .red
		applyStyle()
		XCTAssertEqual(.red, viewCell.selectedBackgroundView?.backgroundColor)
		cell.style?.selectionColor = nil
		applyStyle()
		XCTAssertNil(viewCell.selectedBackgroundView?.backgroundColor)
	}
	
	func testBackground() {
		applyStyle()
		XCTAssertEqual(viewCell.backgroundColor, CellStyle.defaultBackgroundColor)
		cell.style?.backgroundColor = .red
		applyStyle()
		XCTAssertEqual(viewCell.backgroundColor, .red)
		let backgroundViewProvider = ColoredBackgroundProvider(color: .yellow)
		cell.style?.backgroundViewProvider = backgroundViewProvider
		applyStyle()
		XCTAssertEqual(viewCell.backgroundView?.backgroundColor, .yellow)
		cell.style?.backgroundViewProvider = nil
		cell.style?.backgroundColor = nil
		applyStyle()
		XCTAssertNil(viewCell.backgroundColor)
		XCTAssertNil(viewCell.backgroundView?.backgroundColor)
	}
	
	func testTintColor() {
		let ogTint = viewCell.tintColor
		cell.style?.tintColor = .red
		applyStyle()
		XCTAssertEqual(viewCell.tintColor, .red)
		cell.style?.tintColor = nil
		applyStyle()
		XCTAssertEqual(viewCell.tintColor, ogTint)
	}
	
	func testLayoutMargin() {
		let margins = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
		cell.style?.layoutMargins = margins
		applyStyle()
		XCTAssertEqual(viewCell.contentView.layoutMargins, margins)
		cell.style?.layoutMargins = nil
		applyStyle()
		XCTAssertEqual(viewCell.contentView.layoutMargins, UIView().layoutMargins)
	}
	
	func testSelected() {
		cell.style?.selected = true
		applyStyle()
		XCTAssertEqual(viewCell.isSelected, true)
		XCTAssertTrue(tableView.indexPathForSelectedRow == Self.indexPath)
		XCTAssertTrue(tableView.indexPathsForSelectedRows?.contains(Self.indexPath) == true)
		cell.style?.selected = false
		applyStyle()
		XCTAssertEqual(viewCell.isSelected, false)
		XCTAssertTrue(tableView.indexPathForSelectedRow == nil)
		XCTAssertTrue(tableView.indexPathsForSelectedRows == nil)

	}
}
