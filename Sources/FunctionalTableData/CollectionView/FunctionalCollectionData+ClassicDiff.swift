//
//  FunctionalCollectionData+ClassicDiff.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-10-27.
//  Copyright © 2021 Shopify. All rights reserved.

import UIKit

final class ClassicFunctionalCollectionDataDiffer: FunctionalCollectionDataDiffer {
	
	var collectionView: UICollectionView? {
		didSet {
			guard let collectionView = collectionView else { return }
			collectionView.dataSource = dataSource
		}
	}
	
	var isRendering: Bool { renderAndDiffQueue.isSuspended }
	
	func renderAndDiff(_ newSections: [CollectionSection], animated: Bool, completion: (() -> Void)?) {
		let blockOperation = BlockOperation { [weak self] in
			guard let strongSelf = self else {
				if let completion = completion {
					DispatchQueue.main.async(execute: completion)
				}
				return
			}
			
			if strongSelf.unitTesting {
				newSections.validateKeyUniqueness(senderName: strongSelf.name)
			} else {
				NSException.catchAndRethrow({
					newSections.validateKeyUniqueness(senderName: strongSelf.name)
				}, failure: {
					if $0.name == NSExceptionName.internalInconsistencyException {
						guard let exceptionHandler = FunctionalCollectionData.exceptionHandler else { return }
						let changes = CollectionSectionChangeSet()
						let viewFrame = DispatchQueue.main.sync { strongSelf.collectionView?.frame ?? .zero }
						let exception = FunctionalCollectionData.Exception(name: $0.name.rawValue, newSections: newSections, oldSections: strongSelf.sections, changes: changes, visible: [], viewFrame: viewFrame, reason: $0.reason, userInfo: $0.userInfo)
						exceptionHandler.handle(exception: exception)
					}
				})
			}
			
			strongSelf.doRenderAndDiff(newSections, animated: animated, completion: completion)
		}
		renderAndDiffQueue.addOperation(blockOperation)
	}
	private let name: String
	private let dataSource: FunctionalCollectionData.DataSource
	private let renderAndDiffQueue: OperationQueue
	private let unitTesting: Bool
	
	private var data: CollectionData { dataSource.data }
	private var sections: [CollectionSection] { data.sections }
	
	init(name: String, data: CollectionData) {
		self.name = name
		dataSource = FunctionalCollectionData.DataSource(data: data)
		unitTesting = NSClassFromString("XCTestCase") != nil
		
		renderAndDiffQueue = OperationQueue()
		renderAndDiffQueue.name = self.name
		renderAndDiffQueue.maxConcurrentOperationCount = 1
	}
	
	private func doRenderAndDiff(_ newSections: [CollectionSection], animated: Bool, completion: (() -> Void)?) {
		guard let collectionView = collectionView else {
			if let completion = completion {
				DispatchQueue.main.async(execute: completion)
			}
			return
		}
		
		let oldSections = sections
		
		let visibleIndexPaths = DispatchQueue.main.sync {
			collectionView.indexPathsForVisibleItems.filter {
				let section = oldSections[$0.section]
				return $0.item < section.items.count
			}
		}
		
		let localSections = newSections.filter { $0.items.count > 0 }
		let changes = calculateTableChanges(oldSections: oldSections, newSections: localSections, visibleIndexPaths: visibleIndexPaths)
		
		// Use dispatch_sync because the collection updates have to be processed before this function returns
		// or another queued renderAndDiff could get the incorrect state to diff against.
		DispatchQueue.main.sync { [weak self] in
			guard let self = self else {
				completion?()
				return
			}
			
			self.renderAndDiffQueue.isSuspended = true
			collectionView.registerCellsForSections(localSections)
			if oldSections.isEmpty || changes.count > FunctionalCollectionData.reloadEntireTableThreshold || collectionView.isDecelerating || !animated {
				
				self.data.sections = localSections
				
				collectionView.reloadData()
				self.finishRenderAndDiff()
				completion?()
			} else {
				if self.unitTesting {
					self.applyTableChanges(changes, localSections: localSections, completion: {
						self.finishRenderAndDiff()
						completion?()
					})
				} else {
					NSException.catchAndRethrow({
						self.applyTableChanges(changes, localSections: localSections, completion: {
							self.finishRenderAndDiff()
							completion?()
						})
					}, failure: { exception in
						if exception.name == NSExceptionName.internalInconsistencyException {
							self.dumpDebugInfoForChanges(changes, previousSections: oldSections, visibleIndexPaths: visibleIndexPaths, exceptionReason: exception.reason, exceptionUserInfo: exception.userInfo)
						}
					})
				}
			}
		}
	}
	
	internal func calculateTableChanges(oldSections: [CollectionSection], newSections: [CollectionSection], visibleIndexPaths: [IndexPath]) -> CollectionSectionChangeSet {
		return CollectionSectionChangeSet(old: oldSections, new: newSections, visibleIndexPaths: visibleIndexPaths)
	}
	
	private func applyTableChanges(_ changes: CollectionSectionChangeSet, localSections: [CollectionSection], completion: (() -> Void)?) {
		guard let collectionView = collectionView else {
			if let completion = completion {
				DispatchQueue.main.async(execute: completion)
			}
			return
		}
		
		if changes.isEmpty {
			data.sections = localSections
			if let completion = completion {
				DispatchQueue.main.async(execute: completion)
			}
			return
		}
		
		func applyTableSectionChanges(_ changes: CollectionSectionChangeSet) {
			if !changes.insertedSections.isEmpty {
				collectionView.insertSections(changes.insertedSections)
			}
			if !changes.deletedSections.isEmpty {
				collectionView.deleteSections(changes.deletedSections)
			}
			for movedSection in changes.movedSections {
				collectionView.moveSection(movedSection.from, toSection: movedSection.to)
			}
			if !changes.reloadedSections.isEmpty {
				collectionView.reloadSections(changes.reloadedSections)
			}
			
			if !changes.insertedRows.isEmpty {
				collectionView.insertItems(at: changes.insertedRows)
			}
			if !changes.deletedRows.isEmpty {
				collectionView.deleteItems(at: changes.deletedRows)
			}
			for movedRow in changes.movedRows {
				collectionView.moveItem(at: movedRow.from, to: movedRow.to)
			}
			if !changes.reloadedRows.isEmpty {
				collectionView.reloadItems(at: changes.reloadedRows)
			}
		}
		
		func applyTransitionChanges(_ changes: CollectionSectionChangeSet) {
			for update in changes.updates {
				if let cell = collectionView.cellForItem(at: update.index) {
					update.cellConfig.update(cell: cell, in: collectionView)
				}
			}
		}
		
		collectionView.performBatchUpdates({
			data.sections = localSections
			applyTableSectionChanges(changes)
		}) { finished in
			applyTransitionChanges(changes)
			completion?()
		}
	}
	
	private func finishRenderAndDiff() {
		renderAndDiffQueue.isSuspended = false
	}
	
	private func dumpDebugInfoForChanges(_ changes: CollectionSectionChangeSet, previousSections: [CollectionSection], visibleIndexPaths: [IndexPath], exceptionReason: String?, exceptionUserInfo: [AnyHashable: Any]?) {
		guard let exceptionHandler = FunctionalCollectionData.exceptionHandler else { return }
		let exception = FunctionalCollectionData.Exception(name: name, newSections: sections, oldSections: previousSections, changes: changes, visible: visibleIndexPaths, viewFrame: collectionView?.frame ?? .zero, reason: exceptionReason, userInfo: exceptionUserInfo)
		exceptionHandler.handle(exception: exception)
	}
}
