//
//  TableSectionStyleTests.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2017-03-13.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import FunctionalTableData

class TableSectionStyleTests: XCTestCase {
	func cell(key: String, state: String, style: CellStyle? = nil) -> HostCell<UIView, String, LayoutMarginsTableItemLayout> {
		return HostCell<UIView, String, LayoutMarginsTableItemLayout>(key: key, style: style, state: state, cellUpdater: { _,_  in })
	}
	
	func testModifyingItemSeparatorStyleProducesChange() {
		let row1 = cell(key: "row1", state: "red")
		let row2 = cell(key: "row2", state: "red")
		let oldStyle = SectionStyle(separators: SectionStyle.Separators(top: .full, bottom: .full, interitem: nil))
		let newStyle = SectionStyle(separators: SectionStyle.Separators(top: .full, bottom: .full, interitem: .inset))
		let oldSection = TableSection(key: "section", rows: [row1, row2], style: oldStyle)
		let newSection = TableSection(key: "section", rows: [row1, row2], style: newStyle)
		
		let changes = TableSectionChangeSet(
			old: [oldSection],
			new: [newSection],
			visibleIndexPaths: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)]
		)
		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.updates.map { $0.index }, [IndexPath(row: 0, section: 0)])
	}
	
	func testModifyingItemSeparatorStyleProducesNoChangeWithSingleRow() {
		let row1 = cell(key: "row1", state: "red")
		let oldStyle = SectionStyle(separators: SectionStyle.Separators(top: .full, bottom: .full, interitem: nil))
		let newStyle = SectionStyle(separators: SectionStyle.Separators(top: .full, bottom: .full, interitem: .inset))
		let oldSection = TableSection(key: "section", rows: [row1], style: oldStyle)
		let newSection = TableSection(key: "section", rows: [row1], style: newStyle)
		
		let changes = TableSectionChangeSet(
			old: [oldSection],
			new: [newSection],
			visibleIndexPaths: [IndexPath(row: 0, section: 0)]
		)
		XCTAssertTrue(changes.isEmpty)
	}
	
	func testTableSectionStyleEquality() {
		let style = SectionStyle(separators: SectionStyle.Separators(top: .full, bottom: .full, interitem: .inset))
		XCTAssertEqual(style, style)
		XCTAssertNotEqual(style, SectionStyle(separators: SectionStyle.Separators(top: .full, bottom: .full)))
	}
	
	func testTableSectionStyleMerge() {
		let rows: [CellConfigType] = (0..<3).map { return cell(key: "\($0)", state: "\($0)") }
		let style = SectionStyle(separators: .default)
		let section = TableSection(key: "section", rows: rows, style: style)
		
		let styles = (0..<3).compactMap { section.mergedStyle(for: $0) }
		XCTAssertEqual(styles.count, rows.count)
		XCTAssertEqual(styles[0], CellStyle(topSeparator: .full, bottomSeparator: .inset))
		XCTAssertEqual(styles[1], CellStyle(bottomSeparator: .inset))
		XCTAssertEqual(styles[2], CellStyle(bottomSeparator: .full))
	}
	
	func testTableSectionStyleMergeRespectsOverride() {
		let style = SectionStyle(separators: SectionStyle.Separators(top: .full, bottom: .full))
		let section = TableSection(key: "section", rows: [cell(key: "key", state: "state", style: CellStyle(topSeparator: .inset))], style: style)
		let mergedStyle = section.mergedStyle(for: 0)
		XCTAssertEqual(mergedStyle, CellStyle(topSeparator: .inset, bottomSeparator: .full))
	}
	
	func testTableSectionStyleMergePriorityForFirstInteritemSeparator() {
		var rows: [CellConfigType] = (0..<2).map { return cell(key: "\($0)", state: "\($0)") }
		let style = SectionStyle(separators: .full)
		var section = TableSection(key: "section", rows: rows, style: style)
		
		var styles = (0..<2).compactMap { section.mergedStyle(for: $0) }
		XCTAssertEqual(styles[0].topSeparator, .full)
		XCTAssertEqual(styles[0].bottomSeparator, .full)
		XCTAssertEqual(styles[1].bottomSeparator, .full)
		
		rows[1].style = CellStyle(topSeparator: .inset)
		section = TableSection(key: "section", rows: rows, style: style)
		styles = (0..<2).compactMap { section.mergedStyle(for: $0) }
		XCTAssertEqual(styles[0].topSeparator, .full)
		XCTAssertEqual(styles[0].bottomSeparator, .inset)
		XCTAssertEqual(styles[1].bottomSeparator, .full)
		
		rows[0].style = CellStyle(bottomSeparator: .hidden)
		section = TableSection(key: "section", rows: rows, style: style)
		styles = (0..<2).compactMap { section.mergedStyle(for: $0) }
		XCTAssertEqual(styles[0].topSeparator, .full)
		XCTAssertEqual(styles[0].bottomSeparator, .hidden)
		XCTAssertEqual(styles[1].bottomSeparator, .full)
	}
	
	func testTableSectionStyleMergePriorityForMiddleInteritemSeparator() {
		var rows: [CellConfigType] = (0..<3).map { return cell(key: "\($0)", state: "\($0)") }
		let style = SectionStyle(separators: .full)
		var section = TableSection(key: "section", rows: rows, style: style)
		
		var styles = (0..<3).compactMap { section.mergedStyle(for: $0) }
		XCTAssertEqual(styles[0].topSeparator, .full)
		XCTAssertEqual(styles[0].bottomSeparator, .full)
		XCTAssertEqual(styles[1].bottomSeparator, .full)
		XCTAssertEqual(styles[2].bottomSeparator, .full)
		
		rows[2].style = CellStyle(topSeparator: .inset)
		section = TableSection(key: "section", rows: rows, style: style)
		styles = (0..<3).compactMap { section.mergedStyle(for: $0) }
		XCTAssertEqual(styles[0].topSeparator, .full)
		XCTAssertEqual(styles[0].bottomSeparator, .full)
		XCTAssertEqual(styles[1].bottomSeparator, .inset)
		XCTAssertEqual(styles[2].bottomSeparator, .full)
		
		rows[1].style = CellStyle(bottomSeparator: .hidden)
		section = TableSection(key: "section", rows: rows, style: style)
		styles = (0..<3).compactMap { section.mergedStyle(for: $0) }
		XCTAssertEqual(styles[0].topSeparator, .full)
		XCTAssertEqual(styles[0].bottomSeparator, .full)
		XCTAssertEqual(styles[1].bottomSeparator, .hidden)
		XCTAssertEqual(styles[2].bottomSeparator, .full)
	}
}
