//
//  FunctionalTableData+DiffableDataSource.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-03-30.
//  Copyright © 2021 Shopify. All rights reserved.
//

import UIKit

extension FunctionalTableData {
	@available(iOS 13.0, *)
	class DiffableDataSource: UITableViewDiffableDataSource<DiffableTableSection, AnyCellConfigType> {
		let cellStyler: CellStyler
		
		var data: TableData {
			return cellStyler.data
		}
		
		init(tableView: UITableView, cellStyler: CellStyler) {
			self.cellStyler = cellStyler
			super.init(tableView: tableView) { (tableView, indexPath, cellConfigType) in
				let sectionData = cellStyler.data.sections[indexPath.section]
				let cell = cellConfigType.dequeueCell(from: tableView, at: indexPath)
				let accessibilityIdentifier = ItemPath(sectionKey: sectionData.key, itemKey: cellConfigType.key).description
				cellConfigType.accessibility.with(defaultIdentifier: accessibilityIdentifier).apply(to: cell)
				cellStyler.update(cell: cell, cellConfig: cellConfigType, at: indexPath, in: tableView)
				return cell
			}
		}
		
		override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
			guard let cellConfig = data.sections[indexPath] else { return false }
			return cellConfig.actions.hasEditActions || self.tableView(tableView, canMoveRowAt: indexPath) || cellConfig.style?.selected != nil
		}
		
		override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
			return data.sections[indexPath]?.actions.canBeMoved ?? false
		}
		
		override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
			// Should only ever be moving within section
			assert(sourceIndexPath.section == destinationIndexPath.section)
			
			// Update internal state to match move
			let cell = cellStyler.data.sections[sourceIndexPath.section].rows.remove(at: sourceIndexPath.row)
			cellStyler.data.sections[destinationIndexPath.section].rows.insert(cell, at: destinationIndexPath.row)
			cellStyler.data.sections[sourceIndexPath.section].didMoveRow?(sourceIndexPath.row, destinationIndexPath.row)
			super.tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
		}
	}
	
	@available(iOS 13.0, *)
	class DiffableDataSourceFunctionalTableDataImpl: FunctionalTableDataImpl {
		var datasource: DiffableDataSource!
		var isRendering: Bool = false
		let name: String
		let cellStyler: CellStyler
		
		var tableView: UITableView? {
			didSet {
				guard let tableView = tableView else { return }
				let dataSource = DiffableDataSource(tableView: tableView, cellStyler: cellStyler)
				dataSource.defaultRowAnimation = .none
				self.datasource = dataSource
				
			}
		}
		
		init(name: String, cellStyler: CellStyler) {
			self.name = name
			self.cellStyler = cellStyler
		}
		
		func renderAndDiff(_ newSections: [TableSection], animated: Bool, animations: FunctionalTableData.TableAnimations, completion: (() -> Void)?) {
			isRendering = true
			let indexPaths = tableView?.indexPathsForVisibleRows ?? []
			let localSections = newSections.filter { $0.rows.count > 0 }
			tableView?.registerCellsForSections(localSections)
			let oldSections = datasource.data.sections
			let changeSet = TableSectionChangeSet(old: oldSections, new: localSections, visibleIndexPaths: indexPaths)
			datasource.data.sections = localSections
			
			var snapshot = NSDiffableDataSourceSnapshot<DiffableTableSection, AnyCellConfigType>()
			let diffableSections = localSections.map { DiffableTableSection($0) }
			snapshot.appendSections(diffableSections)
			for newSection in diffableSections {
				snapshot.appendItems(newSection.anyRows, toSection: newSection)
			}
			var isFirstRender: Bool = true
			if let snapshot = datasource?.snapshot(), snapshot.numberOfSections == 0 {
				isFirstRender = false
			}
			let shouldAnimate = animated && !isFirstRender
			NSException.catchAndHandle {
				self.datasource.apply(snapshot, animatingDifferences: shouldAnimate, completion: completion)
			} failure: { (exception) in
				NSException.catchAndRethrow {
					self.datasource.apply(snapshot, animatingDifferences: false, completion: completion)
				} failure: { (exception) in
					if exception.name == NSExceptionName.internalInconsistencyException {
						
						dumpDebugInfoForChanges(changeSet,
												previousSections: oldSections,
												visibleIndexPaths: indexPaths,
												exceptionReason: exception.reason,
												exceptionUserInfo: exception.userInfo)
					}
				}
			}
			isRendering = false
		}
		
		private func dumpDebugInfoForChanges(_ changes: TableSectionChangeSet, previousSections: [TableSection], visibleIndexPaths: [IndexPath], exceptionReason: String?, exceptionUserInfo: [AnyHashable: Any]?) {
			guard let exceptionHandler = FunctionalTableData.exceptionHandler else { return }
			let exception = Exception(name: name,
									  newSections: cellStyler.data.sections,
									  oldSections: previousSections,
									  changes: changes,
									  visible: visibleIndexPaths,
									  viewFrame: tableView?.frame ?? .zero,
									  reason: exceptionReason,
									  userInfo: exceptionUserInfo)
			exceptionHandler.handle(exception: exception)
		}
	}
}
