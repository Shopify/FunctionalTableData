//
//  FunctionalCollectionDataTests.swift
//  FunctionalTableDataTests
//
//  Created by Jason Kemp on 2021-10-31.
//  Copyright © 2021 Shopify. All rights reserved.

import XCTest
@testable import FunctionalTableData

class FunctionalCollectionDataTests: XCTestCase {
	func testKeyPathFromRowKey() {
		let functionalData = FunctionalCollectionData()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		functionalData.collectionView = collectionView
		
		let expectation1 = expectation(description: "first append")
		let cellConfigC1 = TestCaseCell(key: "color1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let cellConfigC2 = TestCaseCell(key: "red2", state: TestCaseState(data: "green"), cellUpdater: TestCaseState.updateView)
		let sectionC1 = TableSection(key: "colors Section", rows: [cellConfigC1, cellConfigC2])
		
		let cellConfigS1 = TestCaseCell(key: "size1", state: TestCaseState(data: "medium"), cellUpdater: TestCaseState.updateView)
		let cellConfigS2 = TestCaseCell(key: "size2", state: TestCaseState(data: "large"), cellUpdater: TestCaseState.updateView)
		let sectionS1 = TableSection(key: "sizes Section", rows: [cellConfigS1, cellConfigS2])
		
		functionalData.renderAndDiff([sectionC1, sectionS1]) { [weak functionalData] in
			expectation1.fulfill()
			
			if let functionalData = functionalData, let keyPath = functionalData.keyPathForRowKey("size1") {
				XCTAssertTrue(keyPath.sectionKey == "sizes Section" && keyPath.rowKey == "size1")
			} else {
				XCTFail()
			}
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRetrievingIndexPathFromInvalidKeyPath() {
		let functionalData = FunctionalCollectionData()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		functionalData.collectionView = collectionView
		let expectation1 = expectation(description: "first append")
		let cellConfigC1 = TestCaseCell(key: "red1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let sectionC1 = TableSection(key: "colors Section", rows: [cellConfigC1])
		functionalData.renderAndDiff([sectionC1]) {
			expectation1.fulfill()
		}
		waitForExpectations(timeout: 1, handler: nil)
		
		XCTAssertNil(functionalData.indexPathFromKeyPath(FunctionalTableData.KeyPath(sectionKey: "Invalid Section", rowKey: "red1")))
		XCTAssertNil(functionalData.indexPathFromKeyPath(FunctionalTableData.KeyPath(sectionKey: "colors Section", rowKey: "Invalid Row")))
	}
	
	func testRetrievingIndexPathFromValidKeyPath() {
		let functionalData = FunctionalCollectionData()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		functionalData.collectionView = collectionView
		let expectation1 = expectation(description: "first append")
		let cellConfigC1 = TestCaseCell(key: "red1", state: TestCaseState(data: "red"), cellUpdater: TestCaseState.updateView)
		let sectionC1 = TableSection(key: "colors Section", rows: [cellConfigC1])
		
		functionalData.renderAndDiff([sectionC1]) {
			expectation1.fulfill()
		}
		waitForExpectations(timeout: 1, handler: nil)
		
		let indexPath = functionalData.indexPathFromKeyPath(FunctionalTableData.KeyPath(sectionKey: "colors Section", rowKey: "red1"))
		XCTAssertNotNil(indexPath)
	}
}
