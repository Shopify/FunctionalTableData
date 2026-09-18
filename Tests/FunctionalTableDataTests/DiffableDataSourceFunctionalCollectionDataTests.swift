//
//  DiffableDataSourceFunctionalDataTests.swift
//  FunctionalTableDataTests
//  
//
//  Created by Jason Kemp on 2021-10-31.
//

import XCTest
@testable import FunctionalTableData

class DiffableDataSourceFunctionalCollectionDataTests: XCTestCase {
	func testEqualCellStatesHaveDistinctItemIdentities() {
		let (differ, collectionView) = makeDiffer()
		let sections = [
			SimpleCollectionSection(key: "first", items: [cell("one"), cell("two")]),
			SimpleCollectionSection(key: "second", items: [cell("one")])
		]

		render(sections, with: differ)

		let snapshot = differ.dataSource.snapshot()
		XCTAssertEqual(snapshot.numberOfItems, 3)
		XCTAssertEqual(Set(snapshot.itemIdentifiers.map { $0.hashable }), Set([
			AnyHashable(ItemPath(sectionKey: "first", itemKey: "one")),
			AnyHashable(ItemPath(sectionKey: "first", itemKey: "two")),
			AnyHashable(ItemPath(sectionKey: "second", itemKey: "one"))
		]))
		XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 2)
		XCTAssertEqual(collectionView.numberOfItems(inSection: 1), 1)
	}

	func testContentChangesReloadWithoutChangingIdentity() {
		let (differ, collectionView) = makeDiffer()
		render([SimpleCollectionSection(key: "section", items: [cell("one"), cell("two")])], with: differ)
		let originalItems = differ.dataSource.snapshot().itemIdentifiers
		render([SimpleCollectionSection(key: "section", items: [cell("one", state: "changed"), cell("two")])], with: differ)

		let snapshot = differ.dataSource.snapshot()
		XCTAssertEqual(snapshot.itemIdentifiers, originalItems)
		collectionView.layoutIfNeeded()
		let visibleCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CellConfig<DiffableLabelView, String>.CollectionCellType
		XCTAssertEqual(visibleCell?.view.text, "changed")
	}

	func testEqualStateItemsCanMoveBeInsertedAndBeDeleted() {
		let (differ, collectionView) = makeDiffer()
		render([SimpleCollectionSection(key: "section", items: [cell("one"), cell("two"), cell("three")])], with: differ)
		render([SimpleCollectionSection(key: "section", items: [cell("three"), cell("one"), cell("four")])], with: differ)

		XCTAssertEqual(differ.dataSource.snapshot().itemIdentifiers.map { $0.key }, ["three", "one", "four"])
		XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 3)
	}

	func testDuplicateKeysAreHandledDuringSnapshotConstruction() {
		let invalidSections: [[CollectionSection]] = [
			[SimpleCollectionSection(key: "section", items: [cell("one"), cell("one")])],
			[
				SimpleCollectionSection(key: "section", items: [cell("one")]),
				SimpleCollectionSection(key: "section", items: [cell("two")])
			]
		]
		for sections in invalidSections {
			let (differ, _) = makeDiffer()
			differ.renderAndDiff(sections, animated: false, completion: nil)
			XCTAssertEqual(differ.dataSource.snapshot().numberOfItems, 0)
		}
	}

	private func makeDiffer() -> (DiffableDataSourceFunctionalCollectionDataDiffer, UICollectionView) {
		let differ = DiffableDataSourceFunctionalCollectionDataDiffer(name: "test", data: CollectionData())
		let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), collectionViewLayout: UICollectionViewFlowLayout())
		differ.collectionView = collectionView
		return (differ, collectionView)
	}

	private func cell(_ key: String, state: String = "same") -> CellConfig<DiffableLabelView, String> {
		return CellConfig(key: key, state: state)
	}

	private func render(_ sections: [CollectionSection], with differ: DiffableDataSourceFunctionalCollectionDataDiffer) {
		let completed = expectation(description: "render completed")
		differ.renderAndDiff(sections, animated: false) { completed.fulfill() }
		waitForExpectations(timeout: 1)
	}

	func testKeyPathFromRowKey() {
		let collectionData = FunctionalCollectionData(name: nil, diffingStrategy: .diffableDataSource)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		collectionData.collectionView = collectionView
		
		let expectation1 = expectation(description: "first append")
		let cellConfigC1 = TestCaseCell(key: "color1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let cellConfigC2 = TestCaseCell(key: "red2", state: TestCaseState(data: "green"), cellUpdater: TestCaseState.updateView)
		let sectionC1 = TableSection(key: "colors Section", rows: [cellConfigC1, cellConfigC2])
		
		let cellConfigS1 = TestCaseCell(key: "size1", state: TestCaseState(data: "medium"), cellUpdater: TestCaseState.updateView)
		let cellConfigS2 = TestCaseCell(key: "size2", state: TestCaseState(data: "large"), cellUpdater: TestCaseState.updateView)
		let sectionS1 = TableSection(key: "sizes Section", rows: [cellConfigS1, cellConfigS2])
		
		collectionData.renderAndDiff([sectionC1, sectionS1]) { [weak collectionData] in
			expectation1.fulfill()
			
			if let tableData = collectionData, let keyPath = tableData.keyPathForRowKey("size1") {
				XCTAssertTrue(keyPath.sectionKey == "sizes Section" && keyPath.rowKey == "size1")
			} else {
				XCTFail()
			}
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRetrievingIndexPathFromInvalidKeyPath() {
		let collectionData = FunctionalCollectionData(name: nil, diffingStrategy: .diffableDataSource)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		collectionData.collectionView = collectionView
		let expectation1 = expectation(description: "first append")
		let cellConfigC1 = TestCaseCell(key: "red1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let sectionC1 = TableSection(key: "colors Section", rows: [cellConfigC1])
		collectionData.renderAndDiff([sectionC1]) {
			expectation1.fulfill()
		}
		waitForExpectations(timeout: 1, handler: nil)
		
		XCTAssertNil(collectionData.indexPathFromKeyPath(FunctionalTableData.KeyPath(sectionKey: "Invalid Section", rowKey: "red1")))
		XCTAssertNil(collectionData.indexPathFromKeyPath(FunctionalTableData.KeyPath(sectionKey: "colors Section", rowKey: "Invalid Row")))
	}
	
	func testRetrievingIndexPathFromValidKeyPath() {
		let collectionData = FunctionalCollectionData(name: nil, diffingStrategy: .diffableDataSource)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		collectionData.collectionView = collectionView
		let expectation1 = expectation(description: "first append")
		let cellConfigC1 = TestCaseCell(key: "red1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let sectionC1 = TableSection(key: "colors Section", rows: [cellConfigC1])
		
		collectionData.renderAndDiff([sectionC1]) {
			expectation1.fulfill()
		}
		waitForExpectations(timeout: 1, handler: nil)
		
		let indexPath = collectionData.indexPathFromKeyPath(FunctionalTableData.KeyPath(sectionKey: "colors Section", rowKey: "red1"))
		XCTAssertNotNil(indexPath)
	}

}

private final class DiffableLabelView: UILabel, ConfigurableView {
	func configure(_ state: String) {
		text = state
	}

	func prepareForReuse() {}
}
