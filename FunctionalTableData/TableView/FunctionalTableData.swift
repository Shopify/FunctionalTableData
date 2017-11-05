//
//  FunctionalTableData.swift
//  FunctionalTableData
//
//  Created by Tom Burns on 2016-02-22.
//  Copyright © 2016 Shopify. All rights reserved.
//

import Foundation
import UIKit

/// A type that provides the debugging information when an exception occurs.
public protocol FunctionalTableDataExceptionHandler {
	/// Handles the exception. This is only for debugging purposes, and commonly used
	/// by storing the state information into the filesystem for a developer review.
	///
	/// - Parameter exception: The type of the exception that occurred
	func handle(exception: FunctionalTableData.Exception) -> Void
}

public class FunctionalTableData: NSObject {
	/// A type that provides the information about an exception.
	public struct Exception {
		public let name: String
		public let newSections: [TableSection]
		public let oldSections: [TableSection]
		public let changes: TableSectionChangeSet
		public let visible: [IndexPath]
		public let viewFrame: CGRect
		public let reason: String?
	}
	
	/// Specifies the desired exception handling behaviour.
	public static var exceptionHandler: FunctionalTableDataExceptionHandler?
	
	/// Represents the unique path to a given item in the `FunctionalTableData`.
	///
	/// Think of it as a readable implementation of `IndexPath`, that can be used to locate a given cell
	/// or `TableSection` in the data set.
	public struct KeyPath: Equatable {
		/// Unique identifier for a section.
		public let sectionKey: String
		/// Unique identifier for an item inside a section.
		public let rowKey: String
		
		public init(sectionKey: String, rowKey: String) {
			self.sectionKey = sectionKey
			self.rowKey = rowKey
		}
		
		public static func ==(lhs: KeyPath, rhs: KeyPath) -> Bool {
			return lhs.sectionKey == rhs.sectionKey && lhs.rowKey == rhs.rowKey
		}
	}

	private func dumpDebugInfoForChanges(_ changes: TableSectionChangeSet, previousSections: [TableSection], visibleIndexPaths: [IndexPath], exceptionReason: String?) {
		guard let exceptionHandler = FunctionalTableData.exceptionHandler else { return }
		let exception = Exception(name: name, newSections: sections, oldSections: previousSections, changes: changes, visible: visibleIndexPaths, viewFrame: tableView?.frame ?? .zero, reason: exceptionReason)
		exceptionHandler.handle(exception: exception)
	}
	
	fileprivate var sections: [TableSection] = []
	private static let reloadEntireTableThreshold = 20
	fileprivate var heightAtIndexKeyPath: [String : CGFloat] = [:]
	
	private let renderAndDiffQueue: OperationQueue
	private let name: String
	
	/// Index path for the previously selected row.
	public var indexPathForPreviouslySelectedRow: IndexPath?
	
	/// Enclosing `UITableView` that presents all the `TableSection` data.
	///
	/// `FunctionalTableData` will take care of setting its own `UITableViewDelegate` and
	/// `UITableViewDataSource` and manage all the internals of the `UITableView` on its own.
	public var tableView: UITableView? {
		didSet {
			guard let tableView = tableView else { return }
			tableView.dataSource = self
			tableView.delegate = self
			tableView.rowHeight = UITableViewAutomaticDimension
			tableView.tableFooterView = UIView(frame: .zero)
			tableView.separatorStyle = .none
		}
	}
	
	public subscript(indexPath: IndexPath) -> CellConfigType? {
		return sections[indexPath]
	}

	public var scrollViewDidScroll: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewWillBeginDragging: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewDidEndDragging: ((_ scrollView: UIScrollView, _ decelerate: Bool) -> Void)?
	public var scrollViewDidEndDecelerating: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewDidChangeContentSize: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewDidEndScrollingAnimation: ((_ scrollView: UIScrollView) -> Void)?
	
	/// The type of animation when rows and sections are inserted or deleted.
	public struct TableAnimations {
		public struct Actions {
			let insert: UITableViewRowAnimation
			let delete: UITableViewRowAnimation
			let reload: UITableViewRowAnimation
			public static let `default` = Actions(insert: .fade, delete: .fade, reload: .automatic)
			public static let legacy = Actions(insert: .top, delete: .top, reload: .automatic)

			public init(insert: UITableViewRowAnimation, delete: UITableViewRowAnimation, reload: UITableViewRowAnimation) {
				self.insert = insert
				self.delete = delete
				self.reload = reload
			}
		}
		
		let sections: Actions
		let rows: Actions
		public static var `default` = TableAnimations(sections: .default, rows: .default)
		
		public init(sections: Actions, rows: Actions) {
			self.sections = sections
			self.rows = rows
		}
	}
	
	private let unitTesting: Bool
	
	/// A Boolean value that returns `true` when a `renderAndDiff` pass is currently running.
	public var isRendering: Bool {
		return renderAndDiffQueue.isSuspended
	}
	
	public init(name: String? = nil, fileName: String = #file, lineNumber: Int = #line) {
		self.unitTesting = NSClassFromString("XCTestCase") != nil
		self.name = name ?? "FunctionalTableDataRenderAndDiff-\((fileName as NSString).lastPathComponent):\(lineNumber)"
		renderAndDiffQueue = OperationQueue()
		renderAndDiffQueue.name = self.name
		renderAndDiffQueue.maxConcurrentOperationCount = 1
	}
	
	deinit {
		tableView?.delegate = nil
	}
	
	func updateRow(keyPath: KeyPath, newRow: CellConfigType, completionAction: (() -> Void)? = nil) {
		guard let tableView = tableView else { return }
		if let indexPath = indexPathFromKeyPath(keyPath), let cell = tableView.cellForRow(at: indexPath) {
			newRow.update(cell: cell, in: tableView)
		}
		
		if let sectionIndex = sections.index(where: { $0.key == keyPath.sectionKey }), let rowIndex = sections[sectionIndex].rows.index(where: { $0.key == keyPath.rowKey }) {
			sections[sectionIndex].rows[rowIndex] = newRow
		}
		
		completionAction?()
	}
	
	/// Returns the cell identified by a key path.
	///
	/// - Parameter keyPath: A key path identifying the cell to look up.
	/// - Returns: A `CellConfigType` instance corresponding to the key path or `nil` if the key path is invalid.
	public func rowForKeyPath(_ keyPath: KeyPath) -> CellConfigType? {
		if let sectionIndex = sections.index(where: { $0.key == keyPath.sectionKey }), let rowIndex = sections[sectionIndex].rows.index(where: { $0.key == keyPath.rowKey }) {
			return sections[sectionIndex].rows[rowIndex]
		}
		
		return nil
	}
	
	/// Returns the key path specified by its string presentation.
	///
	/// - Parameter key: String identifier to lookup.
	/// - Returns: A `KeyPath` that matches the key or `nil` if there is no match.
	public func keyPathForRowKey(_ key: String) -> KeyPath? {
		for section in sections {
			for row in section {
				if row.key == key {
					return KeyPath(sectionKey: section.key, rowKey: row.key)
				}
			}
		}
		
		return nil
	}
	
	/// Returns the key path of the cell in a given `IndexPath` location.
	///
	/// __Note:__ This method performs an unsafe lookup, make sure that the `IndexPath` exists
	/// before trying to transform it into a `KeyPath`.
	/// - Parameter indexPath: A key path identifying where the key path is located.
	/// - Returns: The key representation of the supplied `IndexPath`.
	public func keyPathForIndexPath(indexPath: IndexPath) -> KeyPath {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]
		return KeyPath(sectionKey: section.key, rowKey: row.key)
	}
	
	/// Returns the drawing area for a row identified by key path.
	///
	/// - Parameter keyPath: A key path identifying the cell to look up.
	/// - Returns: A rectangle defining the area in which the table view draws the row or `nil` if the key path is invalid.
	public func rectForKeyPath(_ keyPath: KeyPath) -> CGRect? {
		guard let indexPath = indexPathFromKeyPath(keyPath) else { return nil }
		return tableView?.rectForRow(at: indexPath)
	}
	
	private func sectionForKey(key: String) -> TableSection? {
		for section in sections {
			if section.key == key {
				return section
			}
		}
		
		return nil
	}
	
	@available(*, deprecated, message: "The `reloadList` argument is no longer available.")
	public func renderAndDiff(_ newSections: [TableSection], keyPath: KeyPath? = nil, reloadList: Bool, animated: Bool = true, animations: TableAnimations = .default, completion: (() -> Void)? = nil) {
		renderAndDiff(newSections, keyPath: keyPath, animated: animated, animations: animations, completion: completion)
	}
	
	/// Populates the table with the specified sections, and asynchronously updates the table view to reflect the cells and sections that have changed.
	///
	/// - Parameters:
	///   - newSections: An array of TableSection instances to populate the table with. These will replace the previous sections and update any cells that have changed between the old and new sections.
	///   - keyPath: A key path identifying which cell to scroll into view after the render occurs.
	///   - animated: `true` to animate the changes to the table cells, or `false` if the `UITableView` should be updated with no animation.
	///   - animations: Type of animation to perform. See `FunctionalTableData.TableAnimations` for more info.
	///   - completion: Callback that will be called on the main thread once the `UITableView` has finished updating and animating any changes.
	public func renderAndDiff(_ newSections: [TableSection], keyPath: KeyPath? = nil, animated: Bool = true, animations: TableAnimations = .default, completion: (() -> Void)? = nil) {
		let blockOperation = BlockOperation { [weak self] in
			guard let strongSelf = self else {
				if let completion = completion {
					DispatchQueue.main.async(execute: completion)
				}
				return
			}
			
			if Set(newSections.map { $0.key }).count != newSections.count {
				let sectionKeys = newSections.map { $0.key }.joined(separator: ", ")
				let reason = "\(strongSelf.name) : Duplicate Table Section keys"
				let userInfo: [String: Any] = ["Duplicates": sectionKeys]
				NSException(name: NSExceptionName.internalInconsistencyException, reason: reason, userInfo: userInfo).raise()
			}
			
			for section in newSections {
				if Set(section.map { $0.key }).count != section.rows.count {
					let rowKeys = section.rows.map { $0.key }.joined(separator: ", ")
					let reason = "\(strongSelf.name) : Section.Row keys must all be unique"
					let userInfo: [String: Any] = ["Section": section.key, "Duplicates": rowKeys]
					NSException(name: NSExceptionName.internalInconsistencyException, reason: reason, userInfo: userInfo).raise()
				}
			}
			
			strongSelf.doRenderAndDiff(newSections, keyPath: keyPath, animated: animated, animations: animations, completion: completion)
		}
		renderAndDiffQueue.addOperation(blockOperation)
	}
	
	private func doRenderAndDiff(_ newSections: [TableSection], keyPath: KeyPath? = nil, animated: Bool = true, animations: TableAnimations, completion: (() -> Void)? = nil) {
		guard let tableView = tableView else {
			if let completion = completion {
				DispatchQueue.main.async(execute: completion)
			}
			return
		}
		
		let oldSections = sections
		
		var visibleIndexPaths: [IndexPath] = []
		DispatchQueue.main.sync {
			visibleIndexPaths = tableView.indexPathsForVisibleRows?.filter {
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
				strongSelf.sections = localSections
				CATransaction.begin()
				CATransaction.setCompletionBlock {
					strongSelf.finishRenderAndDiff(keyPath: keyPath)
					completion?()
				}
				tableView.reloadData()
				CATransaction.commit()
			} else {
				if strongSelf.unitTesting {
					strongSelf.applyTableChanges(changes, localSections: localSections, animations: animations, completion: {
						strongSelf.finishRenderAndDiff(keyPath: keyPath)
						completion?()
					})
				} else {
					NSException.catchAndRethrow({
						strongSelf.applyTableChanges(changes, localSections: localSections, animations: animations, completion: {
							strongSelf.finishRenderAndDiff(keyPath: keyPath)
							completion?()
						})
					}, failure: { exception in
						if exception.name == NSExceptionName.internalInconsistencyException {
							strongSelf.dumpDebugInfoForChanges(changes, previousSections: oldSections, visibleIndexPaths: visibleIndexPaths, exceptionReason: exception.reason)
						}
					})
				}
			}
		}
	}
	
	private func applyTableChanges(_ changes: TableSectionChangeSet, localSections: [TableSection], animations: TableAnimations, completion: (() -> Void)?) {
		guard let tableView = tableView else {
			if let completion = completion {
				DispatchQueue.main.async(execute: completion)
			}
			return
		}
		
		if changes.isEmpty {
			sections = localSections
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
				if let cell = tableView.cellForRow(at: update.index) {
					update.cellConfig.update(cell: cell, in: tableView)
					
					let section = sections[update.index.section]
					let style = section.mergedStyle(for: update.index.row)
					style?.configure(cell: cell, in: tableView)
				}
			}
		}
		
		CATransaction.begin()
		CATransaction.setCompletionBlock {
			completion?()
		}
		
		tableView.beginUpdates()
		// #4629 - There is an issue where on some occasions calling beginUpdates() will cause a heightForRowAtIndexPath() call to be made. If the sections have been changed already we may no longer find the cells
		// in the model causing a crash. To prevent this from happening, only load the new model AFTER beginUpdates() has run
		sections = localSections
		applyTableSectionChanges(changes)
		tableView.endUpdates()
		
		// Apply transitions after we have commited section/row changes since transition indexPaths are in post-commit space
		tableView.beginUpdates()
		applyTransitionChanges(changes)
		tableView.endUpdates()
		
		CATransaction.commit()
	}

	private func finishRenderAndDiff(keyPath: KeyPath? = nil ) {
		guard let tableView = tableView else { return }
		if let keyPath = keyPath, let indexPath = indexPathFromKeyPath(keyPath) {
			tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
		}
		
		renderAndDiffQueue.isSuspended = false
	}
	
	/// Selects a row in the table view identified by a key path.
	///
	/// - Parameters:
	///   - keyPath: A key path identifying a row in the table view.
	///   - animated: `true` if you want to animate the selection, and `false` if the change should be immediate.
	///   - triggerDelegate: `true` to trigger the `tableView:didSelectRowAt:` delegate from `UITableView` or `false` to skip it. Skipping it is the default `UITableView` behavior.
	public func select(keyPath: KeyPath, animated: Bool = true, triggerDelegate: Bool = false) {
		guard let aTableView = tableView, let indexPath = indexPathFromKeyPath(keyPath) else { return }
		if tableView(aTableView, willSelectRowAt: indexPath) != nil {
			aTableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
			if triggerDelegate {
				tableView(aTableView, didSelectRowAt: indexPath)
			}
		}
	}
	
	public func indexPathFromKeyPath(_ keyPath: KeyPath) -> IndexPath? {
		if let sectionIndex = sections.index(where: { $0.key == keyPath.sectionKey }), let rowIndex = sections[sectionIndex].rows.index(where: { $0.key == keyPath.rowKey }) {
			return IndexPath(row: rowIndex, section: sectionIndex)
		}
		
		return nil
	}
	
	internal func calculateTableChanges(oldSections: [TableSection], newSections: [TableSection], visibleIndexPaths: [IndexPath]) -> TableSectionChangeSet {
		return TableSectionChangeSet(old: oldSections, new: newSections, visibleIndexPaths: visibleIndexPaths)
	}
}

extension UITableView {
	fileprivate func registerCellsForSections(_ sections: [TableSection]) {
		for section in sections {
			for cellConfig in section {
				cellConfig.register(with: self)
			}
			
			if let headerType = section.header {
				headerType.register(with: self)
			}
			
			if let footerType = section.footer {
				footerType.register(with: self)
			}
		}
	}
	
	/// Initiates a layout pass of UITableView and its items. Necessary for calculating new
	/// cell heights and animations when the internal state of a cell changes and needs to reflect
	/// them immediately.
	public func render() {
		OperationQueue.main.addOperation { [weak self] in
			// Don't trigger an update if the table has already left the view hierarchy.
			// This avoids a crash if an update is queued while the table view's controller is being dismissed.
			// q.v. https://github.com/Shopify/mobile-shopify/issues/7372
			if let strongSelf = self, strongSelf.window != nil {
				strongSelf.beginUpdates()
				strongSelf.endUpdates()
			}
		}
	}
	
	/// Deselects the previously selected row, with an option to animate the deselection.
	///
	/// - Parameter animated: `true` to animate the deselection, or `false` if the change should be immediate.
	public func deselectLastSelectedRow(animated: Bool) {
		if let indexPathForSelectedRow = self.indexPathForSelectedRow {
			self.deselectRow(at: indexPathForSelectedRow, animated: animated)
		}
	}
	
	/// Find the `IndexPath` for a particular view. Returns `nil` if the view is not an instance of, or a subview of `UITableViewCell`, or if that cell is not a child of `self`
	///
	/// - Parameter view: The view to find the `IndexPath`.
	/// - Returns: The `IndexPath` of the view in the `UITableView` or `nil` if it could not be found.
	public func indexPath(for view: UIView) -> IndexPath? {
		guard let cell: UITableViewCell = view.typedSuperview() else { return nil }
		return self.indexPath(for: cell)
	}
}

extension FunctionalTableData: UITableViewDataSource {
	public func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sectionData = sections[indexPath.section]
		let row = indexPath.row
		let cellConfig = sectionData[row]
		let cell = cellConfig.dequeueCell(from: tableView, at: indexPath)
		
		cellConfig.update(cell: cell, in: tableView)
		sectionData.mergedStyle(for: row)?.configure(cell: cell, in: tableView)
		
		return cell
	}

	public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		// Should only ever be moving within section
		assert(sourceIndexPath.section == destinationIndexPath.section)

		// Update internal state to match move
		let cell = sections[sourceIndexPath.section].rows.remove(at: sourceIndexPath.row)
		sections[destinationIndexPath.section].rows.insert(cell, at: destinationIndexPath.row)

		sections[sourceIndexPath.section].didMoveRow?(sourceIndexPath.row, destinationIndexPath.row)
	}
}

extension FunctionalTableData: UITableViewDelegate {
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let header = sections[section].header else {
			// When given a height of zero grouped style UITableView's use their default value instead of zero. By returning CGFloat.min we get around this behavior and force UITableView to end up using a height of zero after all.
			return tableView.style == .grouped ? CGFloat.leastNormalMagnitude : 0
		}
		return header.height
	}
	
	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		guard let footer = sections[section].footer else {
			// When given a height of zero grouped style UITableView's use their default value instead of zero. By returning CGFloat.min we get around this behavior and force UITableView to end up using a height of zero after all.
			return tableView.style == .grouped ? CGFloat.leastNormalMagnitude : 0
		}
		return footer.height
	}
	
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		guard indexPath.section < sections.count else { return UITableViewAutomaticDimension }
		if let indexKeyPath = sections[indexPath.section].sectionKeyPathForRow(indexPath.row), let height = heightAtIndexKeyPath[indexKeyPath] {
			return height
		} else {
			return UITableViewAutomaticDimension
		}
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let header = sections[section].header else { return nil }
		return header.dequeueHeaderFooter(from: tableView)
	}
	
	public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		guard let footer = sections[section].footer else { return nil }
		return footer.dequeueHeaderFooter(from: tableView)
	}
	
	public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let cellConfig = sections[indexPath]
		return cellConfig?.actions.selectionAction != nil
	}
	
	public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if tableView.indexPathForSelectedRow == indexPath {
			return nil
		}
		
		indexPathForPreviouslySelectedRow = tableView.indexPathForSelectedRow		
		let cellConfig = sections[indexPath]
		return cellConfig?.actions.selectionAction != nil ? indexPath : nil
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) else { return }
		let cellConfig = sections[indexPath]

		let selectionState = cellConfig?.actions.selectionAction?(cell) ?? .deselected
		if selectionState == .deselected {
			DispatchQueue.main.async {
				tableView.deselectRow(at: indexPath, animated: true)
			}
		}
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard indexPath.section < sections.count else { return }
		
		if let indexKeyPath = sections[indexPath.section].sectionKeyPathForRow(indexPath.row) {
			heightAtIndexKeyPath[indexKeyPath] = cell.bounds.height
		}
		
		if let cellConfig = sections[indexPath] {
			cellConfig.actions.visibilityAction?(cell, true)
			return
		}
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let cellConfig = sections[indexPath] {
			cellConfig.actions.visibilityAction?(cell, false)
			return
		}
	}
	
	public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let tableSection = sections[section]
		tableSection.headerVisibilityAction?(view, true)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
		guard section < sections.count else { return }
		let tableSection = sections[section]
		tableSection.headerVisibilityAction?(view, false)
	}
	
	public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
		let cellConfig = sections[indexPath]
		return cellConfig?.actions.canPerformAction != nil
	}
	
	public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		let cellConfig = sections[indexPath]
		return cellConfig?.actions.canPerformAction?(action) ?? false
	}
	
	public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
		// required
	}

	public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		let cellConfig = sections[indexPath]
		return cellConfig?.actions.rowActions != nil ? .delete : .none
	}

	public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return sections[indexPath]?.actions.canBeMoved ?? false
	}

	public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		return sourceIndexPath.section == proposedDestinationIndexPath.section ? proposedDestinationIndexPath : sourceIndexPath
	}
	
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let cellConfig = sections[indexPath]
		return cellConfig?.actions.rowActions != nil || self.tableView(tableView, canMoveRowAt: indexPath)
	}

	public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let cellConfig = sections[indexPath]
		return cellConfig?.actions.rowActions
	}
	
	// MARK: - UIScrollViewDelegate
	
	@objc public func scrollViewDidChangeContentSize(_ scrollView: UIScrollView) {
		scrollViewDidChangeContentSize?(scrollView)
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollViewDidScroll?(scrollView)
	}
	
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		scrollViewWillBeginDragging?(scrollView)
	}

	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		scrollViewDidEndDragging?(scrollView, decelerate)
	}

	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		scrollViewDidEndDecelerating?(scrollView)
	}
	
	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		scrollViewDidEndScrollingAnimation?(scrollView)
	}
}
