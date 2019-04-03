//
//  FunctionalTableData+UITableViewDataSourcePrefetching.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-25.
//  Copyright © 2019 Shopify. All rights reserved.
//

import Foundation

private extension NSLocking {
	func withLock<T> (_ body: () throws -> T) rethrows -> T {
		self.lock()
		defer { self.unlock() }
		return try body()
	}
}
extension FunctionalTableData {
	class DataSourcePrefetching: NSObject, UITableViewDataSourcePrefetching {
		private struct PrefetchOperation {
			let observations: (finished: NSKeyValueObservation, cancelled: NSKeyValueObservation)
			let operation: Operation
			
			init(operation: Operation, observations: (finished: NSKeyValueObservation, cancelled: NSKeyValueObservation)) {
				self.operation = operation
				self.observations = observations
			}
		}
		
		private let queue = OperationQueue()
		
		private var operations: [ItemPath: PrefetchOperation] = [:]
		private var prefetched: Set<ItemPath> = []
		private let operationsLock = NSLock()
		
		private var operationItemPathsToPrefetch: Set<ItemPath> = []
		private var operationItemPathsToCancel: Set<ItemPath> = []
		
		var sections: [TableSection] = []
		
		private let delay: (prefetch: TimeInterval, cancel: TimeInterval)
		
		init(delay: (prefetch: TimeInterval, cancel: TimeInterval) = (0.1, 0.1)) {
			self.delay = delay
		}
		
		func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
			let itemPaths = sections.itemPaths(from: indexPaths)
			
			operationItemPathsToPrefetch.formUnion(itemPaths)
			operationItemPathsToCancel.subtract(itemPaths)
			
			NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(run), object: nil)
			perform(#selector(run), with: nil, afterDelay: delay.prefetch)
		}
		
		func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
			let itemPaths = sections.itemPaths(from: indexPaths)
			
			// Because we can get rapid fire cancel/prefetch calls that contain the same IndexPath values we queue up ones to be cancelled and delay the cancel
			operationItemPathsToCancel.formUnion(itemPaths)
			operationItemPathsToPrefetch.subtract(itemPaths)
			
			NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(run), object: nil)
			perform(#selector(run), with: nil, afterDelay: delay.cancel)
		}
		
		private func registerOperation(_ operation: Operation, forItemPath itemPath: ItemPath) -> Operation {
			func operationFinished(for itemPath: ItemPath, successfully: Bool) {
				operationsLock.withLock {
					_ = operations.removeValue(forKey: itemPath)
					if successfully {
						prefetched.insert(itemPath)
					}
				}
			}
			
			let finishedObservation = operation.observe(\.isFinished, options: .new) { (operation, change) in
				if change.newValue == true {
					operationFinished(for: itemPath, successfully: true)
				}
			}
			let cancelledObservation = operation.observe(\.isCancelled, options: .new) { (operation, change) in
				if change.newValue == true {
					operationFinished(for: itemPath, successfully: false)
				}
			}
			let prefetchOperation = PrefetchOperation(operation: operation, observations: (finished: finishedObservation, cancelled: cancelledObservation))
			
			operationsLock.withLock {
				operations[itemPath] = prefetchOperation
			}
			
			return operation
		}
		
		@objc private func run() {
			/// Returns `true` if and only if an operation for the given `ItemPath` doesn't already exist and also hasn't already been run.
			///
			/// - Parameter itemPath:
			/// - Returns: `true` if a prefetch operation should be created and run for the given `ItemPath`.
			func shouldPrefetch(itemPath: ItemPath) -> Bool {
				return operationsLock.withLock {
					operations[itemPath] == nil && !prefetched.contains(itemPath)
				}
			}
			
			var newOperations: [Operation] = []
			for itemPath in operationItemPathsToPrefetch where shouldPrefetch(itemPath: itemPath) {
				guard let prefetchAction = sections[itemPath]?.actions.prefetchAction else { continue }
				let operation = prefetchAction()
				newOperations.append(registerOperation(operation, forItemPath: itemPath))
			}
			
			let cancelledOperations = operationsLock.withLock {
				operations.filter { operationItemPathsToCancel.contains($0.key) }.map { $0.value }
			}
			
			operationItemPathsToPrefetch.removeAll()
			operationItemPathsToCancel.removeAll()
			
			queue.addOperations(newOperations, waitUntilFinished: false)
			cancelledOperations.forEach { $0.operation.cancel() }
		}
	}
}
