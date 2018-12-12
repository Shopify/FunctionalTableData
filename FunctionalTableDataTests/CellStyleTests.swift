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
	var cell: UITableViewCell!
	var table: UITableView!
	var style: CellStyle!

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
		cell = UITableViewCell()
		table = UITableView()
		style = CellStyle()
	}
	
	override func tearDown() {
		super.tearDown()
		cell = nil
		table = nil
		style = nil
	}
	
	func testBottomSeparator() {
		style.bottomSeparator = .full
		style.configure(cell: cell, in: table)
		var separator = cell.viewWithTag(Separator.Tag.bottom.rawValue)
		cell.layoutIfNeeded()
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, cell.bounds.width)
		
		style.bottomSeparator = .inset
		style.configure(cell: cell, in: table)
		separator = cell.viewWithTag(Separator.Tag.bottom.rawValue)
		cell.layoutIfNeeded()
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, cell.bounds.width - cell.layoutMarginsGuide.layoutFrame.minX)
		
		style.bottomSeparator = .moreInset
		style.configure(cell: cell, in: table)
		separator = cell.viewWithTag(Separator.Tag.bottom.rawValue)
		cell.layoutIfNeeded()
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, cell.bounds.width - Separator.Style.moreInset.insetDistance)
		
		style.bottomSeparator = nil
		style.configure(cell: cell, in: table)
		separator = cell.viewWithTag(Separator.Tag.bottom.rawValue)
		XCTAssertNil(separator)
	}
	
	func testTopSeparator() {
		style.topSeparator = .full
		style.configure(cell: cell, in: table)
		var separator = cell.viewWithTag(Separator.Tag.top.rawValue)
		cell.layoutIfNeeded()
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, cell.bounds.width)
		
		style.topSeparator = .inset
		style.configure(cell: cell, in: table)
		separator = cell.viewWithTag(Separator.Tag.top.rawValue)
		cell.layoutIfNeeded()
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, cell.bounds.width - cell.layoutMarginsGuide.layoutFrame.minX)
		
		style.topSeparator = .moreInset
		style.configure(cell: cell, in: table)
		separator = cell.viewWithTag(Separator.Tag.top.rawValue)
		cell.layoutIfNeeded()
		XCTAssertNotNil(separator)
		XCTAssertEqual(separator!.bounds.width, cell.bounds.width - Separator.Style.moreInset.insetDistance)
		
		style.topSeparator = nil
		style.configure(cell: cell, in: table)
		separator = cell.viewWithTag(Separator.Tag.top.rawValue)
		XCTAssertNil(separator)
	}
	
	func testHighlight() {
		style.highlight = true
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.selectionStyle, .default)
		style.highlight = false
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.selectionStyle, .none)
		style.highlight = nil
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.selectionStyle, .none)
	}
	
	func testAccessoryType() {
		style.accessoryType = .disclosureIndicator
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.accessoryType, .disclosureIndicator)
		style.accessoryType = .checkmark
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.accessoryType, .checkmark)
		style.accessoryType = .none
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.accessoryType, .none)
	}
	
	func testSelectionColor() {
		style.selectionColor = .red
		style.configure(cell: cell, in: table)
		XCTAssertEqual(.red, cell.selectedBackgroundView?.backgroundColor)
		style.selectionColor = nil
		style.configure(cell: cell, in: table)
		XCTAssertNil(cell.selectedBackgroundView?.backgroundColor)
	}
	
	func testBackground() {
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.backgroundColor, CellStyle.defaultBackgroundColor)
		style.backgroundColor = .red
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.backgroundColor, .red)
		let backgroundViewProvider = ColoredBackgroundProvider(color: .yellow)
		style.backgroundViewProvider = backgroundViewProvider
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.backgroundView?.backgroundColor, .yellow)
		style.backgroundViewProvider = nil
		style.backgroundColor = nil
		style.configure(cell: cell, in: table)
		XCTAssertNil(cell.backgroundColor)
		XCTAssertNil(cell.backgroundView?.backgroundColor)
	}
	
	func testTintColor() {
		let ogTint = cell.tintColor
		style.tintColor = .red
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.tintColor, .red)
		style.tintColor = nil
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.tintColor, ogTint)
	}
	
	func testLayoutMargin() {
		let margins = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
		style.layoutMargins = margins
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.contentView.layoutMargins, margins)
		style.layoutMargins = nil
		style.configure(cell: cell, in: table)
		XCTAssertEqual(cell.contentView.layoutMargins, UIView().layoutMargins)
	}
}
