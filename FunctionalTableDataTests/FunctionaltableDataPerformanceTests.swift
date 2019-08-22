//
//  FunctionaltableDataPerformanceTests.swift
//  FunctionalTableDataTests
//
//  Created by Theo Ben Hassen on 2019-08-22.
//  Copyright © 2019 Shopify. All rights reserved.
//

import XCTest
@testable import FunctionalTableData

class FunctionaltableDataPerformanceTests: XCTestCase {
	private let functionalData = FunctionalTableData()
	
	func testPerformanceByMovingRows() {
		let totalSections = 5
		let totalRows = 200
		
		let oldSections =  mockSections(sectionsCount: totalSections, rowsCount: totalRows) { index -> String in
			return "row-\(index)"
		}

		let newSections: [TableSection] = mockSections(sectionsCount: totalSections, rowsCount: totalRows) { index -> String in
			return "row-\((totalRows - 1) - index)"
		}

		measure {
			_ = functionalData.calculateTableChanges(oldSections: oldSections, newSections: newSections, visibleIndexPaths: [])
		}
	}
	
	func testPerformanceByAddingRows() {
		let newSections: [TableSection] = mockSections(sectionsCount: 10, rowsCount: 10_000) { index -> String in
			return "row-\(index)"
		}
		
		measure {
			_ = functionalData.calculateTableChanges(oldSections: [], newSections: newSections, visibleIndexPaths: [])
		}
	}
	
	func testPerformanceByDeletingRows() {
		let oldSections: [TableSection] = mockSections(sectionsCount: 10, rowsCount: 10_000) { index -> String in
			return "row-\(index)"
		}
		
		measure {
			_ = functionalData.calculateTableChanges(oldSections: oldSections, newSections: [], visibleIndexPaths: [])
		}
	}
	
	func testPerformanceByKeepingRows() {
		let oldSections: [TableSection] = mockSections(sectionsCount: 10, rowsCount: 10_000) { index -> String in
			return "row-\(index)"
		}
		
		let newSections = oldSections
		
		measure {
			_ = functionalData.calculateTableChanges(oldSections: oldSections, newSections: newSections, visibleIndexPaths: [])
		}
	}

	private func mockSections(sectionsCount: Int, rowsCount: Int, keyBuilder: (Int) -> String) -> [TableSection] {
		var sections: [TableSection] = []
		for i in 0..<sectionsCount {
			sections.append(
				TableSection(
					key: "section\(i)",
					rows: (0..<rowsCount).map {
						TestCaseCell(key: keyBuilder($0), state: TestCaseState(data: "data-\(i)"), cellUpdater: TestCaseState.updateView)
					}
				)
			)
		}
		
		return sections
	}
}
