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
			
			if let duplicates = $0.userInfo?["Duplicates"] as? [String] {
				XCTAssertEqual(Set(duplicates), Set(["section1"]))
			} else {
				XCTFail("Missing or malformed user info value for Duplicates")
			}
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
			
			if let section = $0.userInfo?["Section"] as? String {
				XCTAssertEqual(section, "section2")
			} else {
				XCTFail("Missing or malformed user info value for Section")
			}
			
			if let duplicates = $0.userInfo?["Duplicates"] as? [String] {
				XCTAssertEqual(Set(duplicates), Set(["row1", "row4"]))
			} else {
				XCTFail("Missing or malformed user info value for Duplicates")
			}
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
