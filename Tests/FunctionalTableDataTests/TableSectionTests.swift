//
//  TableSectionTests.swift
//  FunctionalTableDataTests
//
//  Created by Adam Becevello on 2019-09-09.
//  Copyright © 2019 Shopify. All rights reserved.
//

import XCTest
@testable import FunctionalTableData

class TableSectionTests: XCTestCase {
	private typealias LabelCell = HostCell<UILabel, String, LayoutMarginsTableItemLayout>
	
	func testEqualitySameObjectReturnsTrue() {
		let first = tableSection()
		let second = tableSection()
		XCTAssertEqual(first, second)
	}
	
	func testEqualityDifferentKeyReturnsFalse() {
		let first = tableSection(key: "first")
		let second = tableSection(key: "second")
		XCTAssertNotEqual(first, second)
	}
	
	func testEqualityNoHeadersReturnsTrue() {
		var first = tableSection()
		first.header = nil
		var second = tableSection()
		second.header = nil
		XCTAssertEqual(first, second)
	}
	
	func testEqualityDifferentHeaderReturnsFalse() {
		let first = tableSection()
		var second = tableSection()
		second.header = TestHeaderFooter(state: TestHeaderFooterState(data: "second"))
		XCTAssertNotEqual(first, second)
	}
	
	func testEqualityNoFootersReturnsTrue() {
		var first = tableSection()
		first.footer = nil
		var second = tableSection()
		second.footer = nil
		XCTAssertEqual(first, second)
	}
	
	func testEqualityDifferentFooterReturnsFalse() {
		let first = tableSection()
		var second = tableSection()
		second.footer = TestHeaderFooter(state: TestHeaderFooterState(data: "second"))
		XCTAssertNotEqual(first, second)
	}
	
	func testEqualityDifferentRowsReturnsFalse() {
		let first = tableSection()
		var second = tableSection()
		second.rows = []
		XCTAssertNotEqual(first, second)
	}
	
	func testEqualityDifferentStyleReturnsFalse() {
		let first = tableSection()
		var second = tableSection()
		second.style = SectionStyle(separators: SectionStyle.Separators(top: Separator.Style.full, bottom: nil, interitem: nil))
		XCTAssertNotEqual(first, second)
	}
	
	func testEqualityNoHeaderVisibilityActionReturnsTrue() {
		var first = tableSection()
		first.headerVisibilityAction = nil
		var second = tableSection()
		second.headerVisibilityAction = nil
		XCTAssertEqual(first, second)
	}
	
	func testEqualityDifferentHeaderVisibilityActionReturnsFalse() {
		let first = tableSection()
		var second = tableSection()
		second.headerVisibilityAction = nil
		XCTAssertNotEqual(first, second)
	}
	
	func testEqualityNoDidMoveRowReturnsTrue() {
		var first = tableSection()
		first.didMoveRow = nil
		var second = tableSection()
		second.didMoveRow = nil
		XCTAssertEqual(first, second)
	}
	
	func testEqualityDifferentDidMoveRowReturnsFalse() {
		let first = tableSection()
		var second = tableSection()
		second.didMoveRow = nil
		XCTAssertNotEqual(first, second)
	}
	
	private func tableSection(key: String = "key") -> TableSection {
		let cell = mockCell(key: "cell", style: nil)
		let header = TestHeaderFooter(state: TestHeaderFooterState(data: "header"))
		let footer = TestHeaderFooter(state: TestHeaderFooterState(data: "footer"))
		let style = SectionStyle(separators: SectionStyle.Separators())
		var tableSection = TableSection(key: key, rows: [cell], header: header, footer: footer, style: style)
		tableSection.didMoveRow = { _, _ in }
		tableSection.headerVisibilityAction = { _, _ in }
		return tableSection
	}
	
	private func mockCell(key: String, style: CellStyle?) -> CellConfigType {
		return LabelCell(
			key: key,
			style: style,
			state: "",
			cellUpdater: { _, _ in })
	}
}

fileprivate struct TestHeaderFooterState: TableHeaderFooterStateType, Equatable {
	let insets: UIEdgeInsets = .zero
	let height: CGFloat = 0
	let topSeparatorHidden: Bool = true
	let bottomSeparatorHidden: Bool = true
	var data: String
}

fileprivate struct TestHeaderFooter: TableHeaderFooterConfigType {
	typealias HeaderFooter = TableHeaderFooter<UIView, LayoutMarginsTableItemLayout>
	let state: TestHeaderFooterState?

	func register(with tableView: UITableView) {
		tableView.registerReusableHeaderFooterView(HeaderFooter.self)
	}

	func dequeueHeaderFooter(from tableView: UITableView) -> UITableViewHeaderFooterView? {
		return tableView.dequeueReusableHeaderFooterView(HeaderFooter.self)
	}

	func isEqual(_ other: TableHeaderFooterConfigType?) -> Bool {
		guard let other = other as? TestHeaderFooter else { return false }
		return state == other.state
	}

	var height: CGFloat {
		return state?.height ?? 0
	}
}
