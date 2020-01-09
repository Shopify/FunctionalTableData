//
//  FunctionalTableData+UITableViewDataSourcePrefetching.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-25.
//  Copyright © 2019 Shopify. All rights reserved.
//

import UIKit

/// A custom implementation of the `UITableViewDataSourcePrefetching` and `UICollectionViewDataSourcePrefetching` protocols that hooks into the `CellAction` type and uses its `prefetchAction: PrefetchAction?`
class DataSourcePrefetching: NSObject, UITableViewDataSourcePrefetching, UICollectionViewDataSourcePrefetching {
	private struct PrefetchOperationWrapper {
		let observations: (finished: NSKeyValueObservation, cancelled: NSKeyValueObservation)
		let operation: Operation
		
		init(operation: Operation, observations: (finished: NSKeyValueObservation, cancelled: NSKeyValueObservation)) {
			self.operation = operation
			self.observations = observations
		}
	}
	
	private let queue = OperationQueue()
	
	private var operations: [ItemPath: PrefetchOperationWrapper] = [:]
	private var prefetched: Set<ItemPath> = []
	private let operationsLock = NSLock()
	
	private var operationItemPathsToPrefetch: Set<ItemPath> = []
	private var operationItemPathsToCancel: Set<ItemPath> = []
	
	private let data: TableData
	
	private let delay: (prefetch: TimeInterval, cancel: TimeInterval)
	
	var isSuspended: Bool = false {
		didSet {
			guard oldValue != isSuspended else { return }
			
			if isSuspended {
				queue.cancelAllOperations()
				operationsLock.withLock {
					operationItemPathsToPrefetch.removeAll()
					operationItemPathsToCancel.removeAll()
					operations.removeAll()
				}
			}
			queue.isSuspended = isSuspended
		}
	}
	
	init(data: TableData, delay: (prefetch: TimeInterval, cancel: TimeInterval) = (0.1, 0.1)) {
		self.data = data
		self.delay = delay
	}
	
	func invalidate(itemPaths: [ItemPath]) {
		operationsLock.withLock {
			prefetched.subtract(itemPaths)
			operationItemPathsToPrefetch.subtract(itemPaths)
			operationItemPathsToCancel.subtract(itemPaths)
			itemPaths.forEach {
				operations[$0]?.operation.cancel()
			}
		}
	}
	
	func invalidate(sections: Set<String>) {
		var itemPaths: Set<ItemPath> = []
		operationsLock.withLock {
			itemPaths.formUnion(prefetched.filter { sections.contains($0.sectionKey) })
			itemPaths.formUnion(operationItemPathsToPrefetch.filter { sections.contains($0.sectionKey) })
			itemPaths.formUnion(operationItemPathsToPrefetch.filter { sections.contains($0.sectionKey) })
		}
		invalidate(itemPaths: Array<ItemPath>(itemPaths))
	}
	
	// MARK: - UITableViewDataSourcePrefetching
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		perform(.prefetch, indexPaths: indexPaths)
	}
	
	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		perform(.cancel, indexPaths: indexPaths)
	}
	
	// MARK: - UICollectionViewDataSourcePrefetching
	
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		perform(.prefetch, indexPaths: indexPaths)
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		perform(.cancel, indexPaths: indexPaths)
	}
	
	// MARK: -
	
	private enum PrefetchOperationKind {
		case prefetch
		case cancel
	}
	
	private func perform(_ kind: PrefetchOperationKind, indexPaths: [IndexPath]) {
		// Because we can get rapid fire cancel/prefetch calls that contain the same IndexPath values we queue up ones to be cancelled and delay the cancel and queue up the fetches and delay the fetch
		let itemPaths = data.sections.itemPaths(from: indexPaths)
		
		let performDelay: TimeInterval
		switch kind {
		case .prefetch:
			operationItemPathsToPrefetch.formUnion(itemPaths)
			operationItemPathsToCancel.subtract(itemPaths)
			performDelay = delay.prefetch
		case .cancel:
			operationItemPathsToCancel.formUnion(itemPaths)
			operationItemPathsToPrefetch.subtract(itemPaths)
			performDelay = delay.cancel
		}
		
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(run), object: nil)
		perform(#selector(run), with: nil, afterDelay: performDelay)
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
		let prefetchOperation = PrefetchOperationWrapper(operation: operation, observations: (finished: finishedObservation, cancelled: cancelledObservation))
		
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
			guard let prefetchAction = data.sections[itemPath]?.actions.prefetchAction else { continue }
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

extension DataSourcePrefetching {
	func invalidatePrefetch(changes: TableSectionChangeSet, newSections: [TableSection]) {
		// Certain changes should result in the prefetcher invalidating the ItemPath's that it is running/has run/will run
		// This is true when:
		//   - a cell was deleted, should no longer run its prefetch if it was queued up
		//   - a cell was reloaded, the cell type or data may have changed
		//   - a cell is being updated, this means a state change on the cell occurred, and that state change may mean that its existing or previously run prefetch is no longer valid
		var invalidatedItemPaths: [ItemPath] = []
		invalidatedItemPaths.append(contentsOf: data.sections.itemPaths(from: changes.deletedRows))
		invalidatedItemPaths.append(contentsOf: data.sections.itemPaths(from: changes.reloadedRows))
		invalidatedItemPaths.append(contentsOf: newSections.itemPaths(from: changes.updates.map { $0.index }))
		invalidate(itemPaths: invalidatedItemPaths)
		
		// A whole section deleted means cancelling all prefetches for it so retrieve the section key for each deleted one
		var invalidatedSections: Set<String> = []
		invalidatedSections.formUnion(changes.deletedSections.map { data.sections[$0].key })
		invalidate(sections: invalidatedSections)
	}
}

private extension NSLocking {
	func withLock<T> (_ body: () throws -> T) rethrows -> T {
		self.lock()
		defer { self.unlock() }
		return try body()
	}
}
