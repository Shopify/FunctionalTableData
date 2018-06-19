//
//  TableSectionsValidationTests.swift
//  FunctionalTableDataTests
//
//  Created by Sherry Shao on 2018-06-15.
//  Copyright © 2018 Shopify. All rights reserved.
//

import XCTest
import Foundation
@testable import FunctionalTableData

class TableSectionsValidationTests: XCTestCase {
	func testValidateKeyUniquenessDoesNotRaiseWhenNoDuplicateSectionAndRowKeys() {
		let sections = [
			sectionWithUniqueRows(key: "section1"),
			sectionWithUniqueRows(key: "section2"),
			sectionWithUniqueRows(key: "section3")
		]
		
		NSException.catchAndHandle({
			sections.validateKeyUniqueness(senderName: "sender")
		}, failure: { _ in
			XCTFail()
		})
	}
	
	func testValidateKeyUniquenessRaisesWhenDuplicateSectionKeys() {
		let sections = [
			sectionWithUniqueRows(key: "section1"),
			sectionWithUniqueRows(key: "section1")
		]
		
		NSException.catchAndHandle({
			sections.validateKeyUniqueness(senderName: "sender")
			XCTFail()
		}, failure: {
			XCTAssertEqual($0.name, NSExceptionName.internalInconsistencyException)
			XCTAssertNotNil($0.userInfo as? [String: Any])
			XCTAssertEqual($0.userInfo!["Duplicates"] as? Set<String>, Set(arrayLiteral: "section1"))
		})
	}
	
	func testValidateKeyUniquenessRaisesWhenDuplicateRowKeys() {
		let sections = [
			sectionWithUniqueRows(key: "section1"),
			sectionWithDuplicateRows(key: "section2")
		]
		
		NSException.catchAndHandle({
			sections.validateKeyUniqueness(senderName: "sender")
			XCTFail()
		}, failure: {
			XCTAssertEqual($0.name, NSExceptionName.internalInconsistencyException)
			XCTAssertNotNil($0.userInfo as? [String: Any])
			XCTAssertEqual($0.userInfo!["Section"] as? String, "section2")
			XCTAssertEqual($0.userInfo!["Duplicates"] as? Set<String>, Set(arrayLiteral: "row1", "row4"))
		})
	}
	
	private func sectionWithUniqueRows(key: String) -> TableSection {
		return TableSection(
			key: key,
			rows: [
				cell(key: "row1"),
				cell(key: "row2"),
				cell(key: "row3")
			]
		)
	}
	
	private func sectionWithDuplicateRows(key: String) -> TableSection {
		return TableSection(
			key: key,
			rows: [
				cell(key: "row1"),
				cell(key: "row1"),
				cell(key: "row1"),
				cell(key: "row4"),
				cell(key: "row4")
			]
		)
	}
	
	private func cell(key: String) -> HostCell<UIView, String, LayoutMarginsTableItemLayout> {
		return HostCell<UIView, String, LayoutMarginsTableItemLayout>(key: key, style: nil, state: "state", cellUpdater: { _,_  in })
	}
}
