//
//  TableSectionChangeSetTests.swift
//  FunctionalTableData
//
//  Created by Bouke van der Bijl on 2017-01-18.
//  Copyright © 2017 Shopify. All rights reserved.
//

import XCTest
@testable import FunctionalTableData

class TableSectionChangeSetTests: XCTestCase {
	func testIsEmpty() {
		let changeset = TableSectionChangeSet()
		XCTAssertTrue(changeset.isEmpty)
		XCTAssertEqual(changeset.count, 0)
	}

	func testAddingSectionsInsertsSections() {
		let oldItems: [TableSection] = []
		let newItems: [TableSection] = [TableSection(key: "section1"), TableSection(key: "section2")]

		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 2)
		XCTAssertEqual(changes.insertedSections, IndexSet([0, 1]))
	}

	func testInsertSectionBefore() {
		let oldItems: [TableSection] = [TableSection(key: "section2"), TableSection(key: "section3"), TableSection(key: "section4")]
		let newItems: [TableSection] = [TableSection(key: "section1"), TableSection(key: "section2"), TableSection(key: "section3"), TableSection(key: "section4")]

		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.movedSections, [])
		XCTAssertEqual(changes.insertedSections, IndexSet(integer: 0))
		XCTAssertEqual(changes.reloadedSections, IndexSet())
		XCTAssertEqual(changes.deletedSections, IndexSet())
	}

	func testInsertAndMoveDown() {
		let oldItems: [TableSection] = [
			TableSection(key: "section2"),
			TableSection(key: "section3")
		]
		let newItems: [TableSection] = [
			TableSection(key: "section1"),
			TableSection(key: "section4"),
			TableSection(key: "section3"),
			TableSection(key: "section2"),
			]

		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 3)
		XCTAssertEqual(changes.movedSections, [TableSectionChangeSet.MovedSection(from: 1, to: 2)])
		XCTAssertEqual(changes.insertedSections, IndexSet([0, 1]))
		XCTAssertEqual(changes.reloadedSections, IndexSet())
		XCTAssertEqual(changes.deletedSections, IndexSet())
	}

	func testSectionNotReloadedWithEqualHeaders() {
		let oldItems: [TableSection] = [TableSection(key: "section1", header: TestHeaderFooter(state: TestHeaderFooterState(data: "green")))]
		let newItems: [TableSection] = [TableSection(key: "section1", header: TestHeaderFooter(state: TestHeaderFooterState(data: "green")))]
		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertTrue(changes.isEmpty)
		XCTAssertEqual(changes.movedSections, [])
		XCTAssertEqual(changes.insertedSections, IndexSet())
		XCTAssertEqual(changes.reloadedSections, IndexSet())
		XCTAssertEqual(changes.deletedSections, IndexSet())
	}

	func testSectionNotReloadedWithEqualFooters() {
		let oldItems: [TableSection] = [TableSection(key: "section1", footer: TestHeaderFooter(state: TestHeaderFooterState(data: "blue")))]
		let newItems: [TableSection] = [TableSection(key: "section1", footer: TestHeaderFooter(state: TestHeaderFooterState(data: "blue")))]
		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertTrue(changes.isEmpty)
		XCTAssertEqual(changes.movedSections, [])
		XCTAssertEqual(changes.insertedSections, IndexSet())
		XCTAssertEqual(changes.reloadedSections, IndexSet())
		XCTAssertEqual(changes.deletedSections, IndexSet())
	}

	func testRowsComparedIfHeadersEqual() {
		let oldItems: [TableSection] = [TableSection(key: "section1", header: TestHeaderFooter(state: TestHeaderFooterState(data: "blue")))]
		let newItems: [TableSection] = [TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
			], header: TestHeaderFooter(state: TestHeaderFooterState(data: "blue"))
		)]
		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.reloadedSections, IndexSet())
		XCTAssertEqual(changes.insertedRows, [IndexPath(item: 0, section: 0)])
	}

	func testSectionReloadedWithInequalHeaders() {
		let oldItems: [TableSection] = [TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
			], header: TestHeaderFooter(state: TestHeaderFooterState(data: "green"))
		)]
		let newItems: [TableSection] = [TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView)
			], header: TestHeaderFooter(state: TestHeaderFooterState(data: "purple"))
		)]
		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.movedSections, [])
		XCTAssertEqual(changes.insertedSections, IndexSet())
		XCTAssertEqual(changes.reloadedSections, IndexSet([0]))
		XCTAssertEqual(changes.deletedSections, IndexSet())
		XCTAssertEqual(changes.insertedRows, [])
		XCTAssertEqual(changes.deletedRows, [])
		XCTAssertEqual(changes.reloadedRows, [])
	}

	func testSectionReloadedWithInequalFooters() {
		let oldItems: [TableSection] = [TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView)
			], footer: TestHeaderFooter(state: TestHeaderFooterState(data: "green"))
		)]
		let newItems: [TableSection] = [TableSection(key: "section1", rows: [
			TestCaseCell(key: "row3", state: TestCaseState(data: "pink"), cellUpdater: TestCaseState.updateView)
			], footer: TestHeaderFooter(state: TestHeaderFooterState(data: "purple"))
		)]
		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.movedSections, [])
		XCTAssertEqual(changes.insertedSections, IndexSet())
		XCTAssertEqual(changes.reloadedSections, IndexSet([0]))
		XCTAssertEqual(changes.deletedSections, IndexSet())
		XCTAssertEqual(changes.insertedRows, [])
		XCTAssertEqual(changes.deletedRows, [])
		XCTAssertEqual(changes.reloadedRows, [])
	}

	func testCorrectSectionReloadedWithDelete() {
		let oldItems: [TableSection] = [
			TableSection(key: "section1"),
			TableSection(key: "section2", footer: TestHeaderFooter(state: TestHeaderFooterState(data: "green")))
		]
		let newItems: [TableSection] = [TableSection(key: "section2", footer: TestHeaderFooter(state: TestHeaderFooterState(data: "purple")))]
		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 2)
		XCTAssertEqual(changes.movedSections, [])
		XCTAssertEqual(changes.insertedSections, IndexSet())
		XCTAssertEqual(changes.reloadedSections, IndexSet([1]))
		XCTAssertEqual(changes.deletedSections, IndexSet([0]))
	}

	func testCorrectSectionReloadedWithInsert() {
		let oldItems: [TableSection] = [
			TableSection(key: "section1", footer: TestHeaderFooter(state: TestHeaderFooterState(data: "green"))),
			TableSection(key: "section2")
		]
		let newItems: [TableSection] = [
			TableSection(key: "section3"),
			TableSection(key: "section1", footer: TestHeaderFooter(state: TestHeaderFooterState(data: "purple"))),
			TableSection(key: "section2")
		]
		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 2)
		XCTAssertEqual(changes.movedSections, [])
		XCTAssertEqual(changes.insertedSections, IndexSet([0]))
		XCTAssertEqual(changes.reloadedSections, IndexSet([0]))
		XCTAssertEqual(changes.deletedSections, IndexSet())
	}

	// Shows the algorithm is greedy
	func testMoveDown() {
		let oldItems: [TableSection] = [
			TableSection(key: "section1"),
			TableSection(key: "section2"),
			TableSection(key: "section3")
		]
		let newItems: [TableSection] = [
			TableSection(key: "section2"),
			TableSection(key: "section3"),
			TableSection(key: "section1"),
			]

		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 2)
		XCTAssertEqual(changes.movedSections, [
			TableSectionChangeSet.MovedSection(from: 1, to: 0),
			TableSectionChangeSet.MovedSection(from: 2, to: 1),
			])
		XCTAssertEqual(changes.insertedSections, IndexSet([]))
		XCTAssertEqual(changes.reloadedSections, IndexSet())
		XCTAssertEqual(changes.deletedSections, IndexSet())
	}

	func testSwap() {
		let oldItems: [TableSection] = [
			TableSection(key: "section1"),
			TableSection(key: "section2"),
			TableSection(key: "section3"),
			TableSection(key: "section4"),
			TableSection(key: "section5"),
		]
		let newItems: [TableSection] = [
			TableSection(key: "section3"),
			TableSection(key: "section2"),
			TableSection(key: "section1"),
			TableSection(key: "section4"),
			TableSection(key: "section5"),
			]

		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 2)
		XCTAssertEqual(changes.movedSections, [
			TableSectionChangeSet.MovedSection(from: 2, to: 0),
			TableSectionChangeSet.MovedSection(from: 1, to: 1),
			])
		XCTAssertEqual(changes.insertedSections, IndexSet([]))
		XCTAssertEqual(changes.reloadedSections, IndexSet())
		XCTAssertEqual(changes.deletedSections, IndexSet())
	}

	func testRemovingSectionsDeletesSections() {
		let oldItems: [TableSection] = [TableSection(key: "section1"), TableSection(key: "section2")]
		let newItems: [TableSection] = []

		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 2)
		XCTAssertEqual(changes.deletedSections, IndexSet([0, 1]))
	}

	func testRemovingPreviousSectionDoesntCauseMove() {
		let oldItems: [TableSection] = [TableSection(key: "section1"), TableSection(key: "section2")]
		let newItems: [TableSection] = [TableSection(key: "section2")]

		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.deletedSections, IndexSet([0]))
		XCTAssertEqual(changes.movedSections, [])
	}

	func testReloadingSection() {
		let oldItems: [TableSection] = [TableSection(key: "section1")]
		let newItems: [TableSection] = [TableSection(key: "section2")]

		let changes = TableSectionChangeSet(old: oldItems, new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 2)
		XCTAssertEqual(changes.deletedSections, IndexSet(integer: 0))
		XCTAssertEqual(changes.insertedSections, IndexSet(integer: 0))
		XCTAssertEqual(changes.reloadedSections, IndexSet())
		XCTAssertEqual(changes.movedSections, [])
	}

	func testAddingSectionAndRowOnlyInsertsSection() {
		let oldItems: [TableSection] = []
		let rows: [CellConfigType] = [TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)]
		let newSection = TableSection(key: "section1", rows: rows)

		let changes = TableSectionChangeSet(old: oldItems, new: [newSection], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.insertedSections, IndexSet([0]))
	}

	func testDeletingSectionAndRowOnlyDeletesSection() {
		let newItems: [TableSection] = []
		let rows: [CellConfigType] = [TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)]
		let oldSection = TableSection(key: "section1", rows: rows)

		let changes = TableSectionChangeSet(old: [oldSection], new: newItems, visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.deletedSections, IndexSet([0]))
	}

	func testAddingNewRowsInsertsRows() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			])
		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView)
			])

		let changes = TableSectionChangeSet(old: [oldSection], new: [newSection], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.insertedRows, [IndexPath(row: 1, section: 0)])
	}

	func testAddingNewRowsBefore() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row3", state: TestCaseState(data: "pink"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row4", state: TestCaseState(data: "cyan"), cellUpdater: TestCaseState.updateView)
			])
		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row3", state: TestCaseState(data: "pink"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row4", state: TestCaseState(data: "cyan"), cellUpdater: TestCaseState.updateView)
			])

		let changes = TableSectionChangeSet(old: [oldSection], new: [newSection], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.insertedRows, [IndexPath(row: 0, section: 0)])
		XCTAssertEqual(changes.movedRows, [])
	}

	func testRemovingRowRemovesRowsFromTable() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView)
			])

		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
			])

		let changes = TableSectionChangeSet(old: [oldSection], new: [newSection], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.deletedRows, [IndexPath(row: 1, section: 0)])
	}

	func testRemovingPreviousRowDoesntCauseMove() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView)
			])

		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView)
			])

		let changes = TableSectionChangeSet(old: [oldSection], new: [newSection], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.deletedRows, [IndexPath(row: 0, section: 0)])
		XCTAssertEqual(changes.movedRows, [])
	}

	func testSwappingRows() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView),
			])

		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
			])

		let changes = TableSectionChangeSet(old: [oldSection], new: [newSection], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.movedRows, [
			TableSectionChangeSet.MovedRow(
				from: IndexPath(row: 1, section: 0),
				to: IndexPath(row: 0, section: 0)
			)
			])
	}

	func testRemoveOneAddTwo() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView),
			])

		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row3", state: TestCaseState(data: "green"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row4", state: TestCaseState(data: "purple"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView)
			])

		let changes = TableSectionChangeSet(old: [oldSection], new: [newSection], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 3)
		XCTAssertEqual(changes.deletedRows, [IndexPath(row: 0, section: 0)])
		XCTAssertEqual(changes.insertedRows, [
			IndexPath(row: 0, section: 0),
			IndexPath(row: 1, section: 0),
			])
		XCTAssertEqual(changes.reloadedRows, [])
		XCTAssertEqual(changes.movedRows, [])
	}

	func testChangingSingleItemUpdatesRow() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			])

		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView),
			])

		let changes = TableSectionChangeSet(old: [oldSection], new: [newSection], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 2)
		XCTAssertEqual(changes.deletedRows, [IndexPath(row: 0, section: 0)])
		XCTAssertEqual(changes.insertedRows, [IndexPath(row: 0, section: 0)])
		XCTAssertEqual(changes.reloadedRows, [])
	}

	func testInsertSectionAndMoveRowInNext() {
		let staticSection1 = TableSection(key: "staticSection", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView),
			])
		let staticSection2 = TableSection(key: "staticSection", rows: staticSection1.rows.reversed())

		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView),
			])

		let changes = TableSectionChangeSet(old: [staticSection1], new: [newSection, staticSection2], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 2)
		XCTAssertEqual(changes.insertedSections, IndexSet(integer: 0))
		XCTAssertEqual(changes.movedRows, [
			TableSectionChangeSet.MovedRow(
				from: IndexPath(row: 1, section: 0),
				to: IndexPath(row: 0, section: 1)
			)
			])
		XCTAssertTrue(changes.movedSections.isEmpty)
	}

	func testRemoveSectionAndReplaceRowInNextSection() {
		let section1 = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView)
			])
		let newSection1 = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
			])

		let section2 = TableSection(key: "section2", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView)
			])

		let changes = TableSectionChangeSet(old: [section2, section1], new: [newSection1], visibleIndexPaths: [])

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 3)
		XCTAssertEqual(changes.insertedSections, IndexSet())
		XCTAssertEqual(changes.deletedSections, IndexSet(integer: 0))
		XCTAssertEqual(changes.reloadedSections, IndexSet())
		XCTAssertTrue(changes.movedSections.isEmpty)
		// Is section 1 because reload indexpaths are pre-transaction
		XCTAssertEqual(changes.reloadedRows, [])
		XCTAssertEqual(changes.insertedRows, [IndexPath(row: 0, section: 0)])
		XCTAssertEqual(changes.deletedRows, [IndexPath(row: 0, section: 1)])
		XCTAssertEqual(changes.movedRows, [])
	}

	func testSwapSections() {
		let section1 = TableSection(key: "section1")
		let section2 = TableSection(key: "section2")

		let changes = TableSectionChangeSet(
			old: [section1, section2],
			new: [section2, section1],
			visibleIndexPaths: []
		)

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.insertedSections, IndexSet())
		XCTAssertEqual(changes.movedSections, [TableSectionChangeSet.MovedSection(from: 1, to: 0)])
	}

	func testRemovingPreviousAndUpdating() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row2", state: TestCaseState(data: "blue"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row3", state: TestCaseState(data: "green"), cellUpdater: TestCaseState.updateView)
		])

		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row2", state: TestCaseState(data: "purple"), cellUpdater: TestCaseState.updateView),
			TestCaseCell(key: "row3", state: TestCaseState(data: "cyan"), cellUpdater: TestCaseState.updateView)
		])

		let changes = TableSectionChangeSet(
			old: [oldSection],
			new: [newSection],
			visibleIndexPaths: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)]
		)

		XCTAssertFalse(changes.isEmpty)
		XCTAssertEqual(changes.count, 3)
		XCTAssertEqual(changes.deletedRows, [IndexPath(row: 0, section: 0)])
		XCTAssertEqual(changes.updates.map { $0.index }, [
			IndexPath(row: 0, section: 0),
			IndexPath(row: 1, section: 0),
		])
	}
	
	func testUpdateRowState() {
		let oldState = TestCaseState(data: "Old state")
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: oldState, cellUpdater: TestCaseState.updateView)
		])

		let newState = TestCaseState(data: "Plain text")
		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: newState, cellUpdater: TestCaseState.updateView)
		])
		
		let changes = TableSectionChangeSet(
			old: [oldSection],
			new: [newSection],
			visibleIndexPaths: [IndexPath(row: 0, section: 0)]
		)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.updates.map { $0.index }, [
			IndexPath(row: 0, section: 0),
			])
	}
	
	func testUpdateRowConfig() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		])
		
		let newSection = TableSection(key: "section1", rows: [
			LabelCell(key: "row1", state: "green") { view, state in
				view.text = state
			}
		])
		
		let changes = TableSectionChangeSet(
			old: [oldSection],
			new: [newSection],
			visibleIndexPaths: [IndexPath(row: 0, section: 0)]
		)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.reloadedRows, [IndexPath(row: 0, section: 0)])
	}
	
	func testAccessibilityChange() {
		let oldSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", accessibility: Accessibility(identifier: "initial", userInputLabels: ["row1"]), state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		])
		
		let newSection = TableSection(key: "section1", rows: [
			TestCaseCell(key: "row1", accessibility: Accessibility(identifier: "new", userInputLabels: ["row1"]), state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		])
		
		let changes = TableSectionChangeSet(
			old: [oldSection],
			new: [newSection],
			visibleIndexPaths: [IndexPath(row: 0, section: 0)]
		)
		XCTAssertEqual(changes.count, 1)
		XCTAssertEqual(changes.updates.map { $0.index }, [IndexPath(row: 0, section: 0)])
	}
}

fileprivate typealias LabelCell = HostCell<UILabel, String, LayoutMarginsTableItemLayout>

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
