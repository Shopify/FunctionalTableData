//
//  FunctionalTableData+Classic.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-03-30.
//  Copyright © 2021 Shopify. All rights reserved.
//

import UIKit

extension FunctionalTableData {
	class ClassicFunctionalTableDataImpl: FunctionalTableDataImpl {
		func renderAndDiff(_ newSections: [TableSection], animated: Bool, animations: FunctionalTableData.TableAnimations, completion: (() -> Void)?) {
			let blockOperation = BlockOperation { [weak self] in
				guard let strongSelf = self else {
					if let completion = completion {
						DispatchQueue.main.async(execute: completion)
					}
					return
				}
				
				
				NSException.catchAndRethrow({
					newSections.validateKeyUniqueness(senderName: strongSelf.name)
				}, failure: {
					if $0.name == NSExceptionName.internalInconsistencyException {
						guard let exceptionHandler = FunctionalTableData.exceptionHandler else { return }
						let changes = TableSectionChangeSet()
						let viewFrame = DispatchQueue.main.sync { strongSelf.tableView?.frame ?? .zero }
						let exception = Exception(name: $0.name.rawValue, newSections: newSections, oldSections: strongSelf.dataSource.data.sections, changes: changes, visible: [], viewFrame: viewFrame, reason: $0.reason, userInfo: $0.userInfo)
						exceptionHandler.handle(exception: exception)
					}
				})
				
				strongSelf.doRenderAndDiff(newSections, animated: animated, animations: animations, completion: completion)
			}
			//cancel waiting operations since only the last state needs to be rendered
			renderAndDiffQueue.operations.lazy.filter { !$0.isExecuting }.forEach { $0.cancel() }
			renderAndDiffQueue.addOperation(blockOperation)
		}
		private let name: String
		private let dataSource: DataSource
		private let renderAndDiffQueue: OperationQueue
		var tableView: UITableView? {
			didSet {
				guard let tableView = tableView else { return }
				tableView.dataSource = dataSource
			}
		}
		
		var isRendering: Bool {
			renderAndDiffQueue.isSuspended
		}
		private let unitTesting: Bool
		
		init(name: String, cellStyler: CellStyler) {
			self.name = name
			dataSource = DataSource(cellStyler: cellStyler)
			unitTesting = NSClassFromString("XCTestCase") != nil
			renderAndDiffQueue = OperationQueue()
			renderAndDiffQueue.name = name
			renderAndDiffQueue.maxConcurrentOperationCount = 1
		}
		
		private func doRenderAndDiff(_ newSections: [TableSection], animated: Bool, animations: TableAnimations, completion: (() -> Void)?) {
			guard let tableView = tableView else {
				if let completion = completion {
					DispatchQueue.main.async(execute: completion)
				}
				return
			}
			let oldSections = dataSource.data.sections
			
			let visibleIndexPaths = DispatchQueue.main.sync {
				tableView.indexPathsForVisibleRows?.filter {
					let section = oldSections[$0.section]
					return $0.row < section.rows.count
				} ?? []
			}
			
			let localSections = newSections.filter { $0.rows.count > 0 }
			let changes = calculateTableChanges(oldSections: oldSections, newSections: localSections, visibleIndexPaths: visibleIndexPaths)
			
			// Use dispatch_sync because the table updates have to be processed before this function returns
			// or another queued renderAndDiff could get the incorrect state to diff against.
			DispatchQueue.main.sync { [weak self] in
				guard let strongSelf = self else {
					completion?()
					return
				}
				
				strongSelf.renderAndDiffQueue.isSuspended = true
				tableView.registerCellsForSections(localSections)
				if oldSections.isEmpty || changes.count > FunctionalTableData.reloadEntireTableThreshold || tableView.isDecelerating || !animated {
					strongSelf.dataSource.data.sections = localSections
					CATransaction.begin()
					CATransaction.setCompletionBlock {
						strongSelf.finishRenderAndDiff()
						completion?()
					}
					tableView.reloadData()
					CATransaction.commit()
				} else {
					if strongSelf.unitTesting {
						strongSelf.applyTableChanges(changes, localSections: localSections, animations: animations, completion: {
							strongSelf.finishRenderAndDiff()
							completion?()
						})
					} else {
						NSException.catchAndRethrow({
							strongSelf.applyTableChanges(changes, localSections: localSections, animations: animations, completion: {
								strongSelf.finishRenderAndDiff()
								completion?()
							})
						}, failure: { exception in
							if exception.name == NSExceptionName.internalInconsistencyException {
								strongSelf.dumpDebugInfoForChanges(changes, previousSections: oldSections, visibleIndexPaths: visibleIndexPaths, exceptionReason: exception.reason, exceptionUserInfo: exception.userInfo)
							}
						})
					}
				}
			}
		}
		
		private func finishRenderAndDiff() {
			renderAndDiffQueue.isSuspended = false
		}
		
		internal func calculateTableChanges(oldSections: [TableSection], newSections: [TableSection], visibleIndexPaths: [IndexPath]) -> TableSectionChangeSet {
			return TableSectionChangeSet(old: oldSections, new: newSections, visibleIndexPaths: visibleIndexPaths)
		}
		
		private func applyTableChanges(_ changes: TableSectionChangeSet, localSections: [TableSection], animations: TableAnimations, completion: (() -> Void)?) {
			guard let tableView = tableView else {
				if let completion = completion {
					DispatchQueue.main.async(execute: completion)
				}
				return
			}
			
			if changes.isEmpty {
				dataSource.data.sections = localSections
				if let completion = completion {
					DispatchQueue.main.async(execute: completion)
				}
				return
			}
			
			func applyTableSectionChanges(_ changes: TableSectionChangeSet) {
				if !changes.insertedSections.isEmpty {
					tableView.insertSections(changes.insertedSections, with: animations.sections.insert)
				}
				if !changes.deletedSections.isEmpty {
					tableView.deleteSections(changes.deletedSections, with: animations.sections.delete)
				}
				for movedSection in changes.movedSections {
					tableView.moveSection(movedSection.from, toSection: movedSection.to)
				}
				if !changes.reloadedSections.isEmpty {
					tableView.reloadSections(changes.reloadedSections, with: animations.sections.reload)
				}
				
				if !changes.insertedRows.isEmpty {
					tableView.insertRows(at: changes.insertedRows, with: animations.rows.insert)
				}
				if !changes.deletedRows.isEmpty {
					tableView.deleteRows(at: changes.deletedRows, with: animations.rows.delete)
				}
				for movedRow in changes.movedRows {
					tableView.moveRow(at: movedRow.from, to: movedRow.to)
				}
				if !changes.reloadedRows.isEmpty {
					tableView.reloadRows(at: changes.reloadedRows, with: animations.rows.reload)
				}
			}
			
			func applyTransitionChanges(_ changes: TableSectionChangeSet) {
				for update in changes.updates {
					dataSource.cellStyler.update(cellConfig: update.cellConfig, at: update.index, in: tableView)
				}
			}
			
			CATransaction.begin()
			CATransaction.setCompletionBlock {
				completion?()
			}
			
			tableView.beginUpdates()
			// #4629 - There is an issue where on some occasions calling beginUpdates() will cause a heightForRowAtIndexPath() call to be made. If the sections have been changed already we may no longer find the cells
			// in the model causing a crash. To prevent this from happening, only load the new model AFTER beginUpdates() has run
			dataSource.data.sections = localSections
			applyTableSectionChanges(changes)
			tableView.endUpdates()
			
			// Apply transitions after we have commited section/row changes since transition indexPaths are in post-commit space
			tableView.beginUpdates()
			applyTransitionChanges(changes)
			tableView.endUpdates()
			
			CATransaction.commit()
		}
		
		private func dumpDebugInfoForChanges(_ changes: TableSectionChangeSet, previousSections: [TableSection], visibleIndexPaths: [IndexPath], exceptionReason: String?, exceptionUserInfo: [AnyHashable: Any]?) {
			guard let exceptionHandler = FunctionalTableData.exceptionHandler else { return }
			let exception = Exception(name: name, newSections: dataSource.data.sections, oldSections: previousSections, changes: changes, visible: visibleIndexPaths, viewFrame: tableView?.frame ?? .zero, reason: exceptionReason, userInfo: exceptionUserInfo)
			exceptionHandler.handle(exception: exception)
		}
	}
}
