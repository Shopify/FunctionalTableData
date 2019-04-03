//
//  FunctionalTableDataPrefetchTests.swift
//  FunctionalTableDataTests
//
//  Created by Geoffrey Foster on 2019-04-03.
//  Copyright © 2019 Shopify. All rights reserved.
//

import XCTest
@testable import FunctionalTableData

class FunctionalTableDataPrefetchTests: XCTestCase {
	private class TestOperation: BlockOperation {
		let mainExpectation: XCTestExpectation?
		let cancelExpectation: XCTestExpectation?
		
		public init(mainExpectation: XCTestExpectation? = nil, cancelExpectation: XCTestExpectation? = nil, block: (() -> Void)? = nil) {
			self.mainExpectation = mainExpectation
			self.cancelExpectation = cancelExpectation
			super.init()
			if let block = block {
				addExecutionBlock(block)
			}
		}
		
		override func main() {
			super.main()
			mainExpectation?.fulfill()
		}
		
		override func cancel() {
			super.cancel()
			cancelExpectation?.fulfill()
		}
	}
	
	private func section(withPrefetch prefetchAction: @escaping CellActions.PrefetchAction) -> TableSection {
		let actions = CellActions(prefetchAction: prefetchAction)
		let cell = HostCell<UIView, String, LayoutMarginsTableItemLayout>(key: "prefetch-cell", actions: actions, state: "Actions") { (_, _) in }
		return TableSection(key: "prefetch-section", rows: [cell])
	}
	
	let tableView = UITableView(frame: .zero, style: .plain)
	let indexPaths = [IndexPath(row: 0, section: 0)]
	
	func testPrefetch() {
		let prefetchCalledExpectation = expectation(description: "Prefetch action not called")
		let prefetchDataSource = FunctionalTableData.DataSourcePrefetching()
		prefetchDataSource.sections = [
			section(withPrefetch: { () -> Operation in
				return TestOperation(mainExpectation: prefetchCalledExpectation)
			})
		]
		
		prefetchDataSource.tableView(tableView, prefetchRowsAt: indexPaths)
		wait(for: [prefetchCalledExpectation], timeout: 1)
	}
	
	func testPrefetchCancel() {
		let prefetchOperationExpectation = expectation(description: "Prefetch operation should have been called")
		let prefetchCancelExpectation = expectation(description: "Cancel should have been called")
		let prefetchDataSource = FunctionalTableData.DataSourcePrefetching()
		prefetchDataSource.sections = [
			section(withPrefetch: { () -> Operation in
				prefetchOperationExpectation.fulfill()
				return TestOperation(cancelExpectation: prefetchCancelExpectation) {
					Thread.sleep(forTimeInterval: 1)
				}
			})
		]
		
		prefetchDataSource.tableView(tableView, prefetchRowsAt: indexPaths)
		wait(for: [prefetchOperationExpectation], timeout: 1)
		prefetchDataSource.tableView(tableView, cancelPrefetchingForRowsAt: indexPaths)
		wait(for: [prefetchCancelExpectation], timeout: 1)
	}
	
	func testPrefetchCancelResume() {
		let prefetchMainExpectation = expectation(description: "Main should have been called")
		let prefetchCancelExpectation = expectation(description: "Cancel should not have been called")
		prefetchCancelExpectation.isInverted = true
		let prefetchDataSource = FunctionalTableData.DataSourcePrefetching()
		prefetchDataSource.sections = [
			section(withPrefetch: { () -> Operation in
				let op = TestOperation(mainExpectation: prefetchMainExpectation, cancelExpectation: prefetchCancelExpectation) {
					Thread.sleep(forTimeInterval: 0.1)
				}
				return op
			})
		]
		
		prefetchDataSource.tableView(tableView, prefetchRowsAt: indexPaths)
		prefetchDataSource.tableView(tableView, cancelPrefetchingForRowsAt: indexPaths)
		prefetchDataSource.tableView(tableView, prefetchRowsAt: indexPaths)
		wait(for: [prefetchMainExpectation, prefetchCancelExpectation], timeout: 1)
	}
}
