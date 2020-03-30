//
//  FunctionalTableData.swift
//  FunctionalTableData
//
//  Created by Tom Burns on 2016-02-22.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

/// A type that provides the debugging information when an exception occurs.
public protocol FunctionalTableDataExceptionHandler {
	/// Handles the exception. This is only for debugging purposes, and commonly used
	/// by storing the state information into the filesystem for a developer review.
	///
	/// - Parameter exception: The type of the exception that occurred
	func handle(exception: FunctionalTableData.Exception) -> Void
}

/// A renderer for `UITableView`.
///
/// By providing a complete description of your view state using an array of `TableSection`. `FunctionalTableData` compares it with the previous render call to insert, update, and remove everything that have changed. This massively simplifies state management of complex UI.
public class FunctionalTableData {
	/// A type that provides the information about an exception.
	public struct Exception {
		public let name: String
		public let newSections: [TableSection]
		public let oldSections: [TableSection]
		public let changes: TableSectionChangeSet
		public let visible: [IndexPath]
		public let viewFrame: CGRect
		public let reason: String?
		public let userInfo: [AnyHashable: Any]?
	}
	
	/// Specifies the desired exception handling behaviour.
	public static var exceptionHandler: FunctionalTableDataExceptionHandler?
	
	public typealias KeyPath = ItemPath
	
	private func dumpDebugInfoForChanges(_ changes: TableSectionChangeSet, previousSections: [TableSection], visibleIndexPaths: [IndexPath], exceptionReason: String?, exceptionUserInfo: [AnyHashable: Any]?) {
		guard let exceptionHandler = FunctionalTableData.exceptionHandler else { return }
		let exception = Exception(name: name, newSections: data.sections, oldSections: previousSections, changes: changes, visible: visibleIndexPaths, viewFrame: tableView?.frame ?? .zero, reason: exceptionReason, userInfo: exceptionUserInfo)
		exceptionHandler.handle(exception: exception)
	}
	
	private let data: TableData
	private static let reloadEntireTableThreshold = 20
	
	private let renderAndDiffQueue: OperationQueue
	private let name: String
	
	private let cellStyler: CellStyler
	private let dataSource: DataSource
	internal let delegate: Delegate
	
	/// Enclosing `UITableView` that presents all the `TableSection` data.
	///
	/// `FunctionalTableData` will take care of setting its own `UITableViewDelegate` and
	/// `UITableViewDataSource` and manage all the internals of the `UITableView` on its own.
	public var tableView: UITableView? {
		didSet {
			guard let tableView = tableView else { return }
			tableView.dataSource = dataSource
			tableView.delegate = delegate
			tableView.rowHeight = UITableView.automaticDimension
			tableView.tableFooterView = UIView(frame: .zero)
			tableView.separatorStyle = .none
		}
	}
	
	public subscript(indexPath: IndexPath) -> CellConfigType? {
		return data.sections[indexPath]
	}
	
	/// An object to receive various [UIScrollViewDelegate](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate) related events
	public weak var scrollViewDelegate: UIScrollViewDelegate? {
		get {
			return delegate.scrollViewDelegate
		}
		set {
			delegate.scrollViewDelegate = newValue
			
			// Reset the delegate, this triggers UITableView and UIScrollView to re-cache their available delegate methods
			tableView?.delegate = nil
			tableView?.delegate = delegate
		}
	}
	
	/// The type of animation when rows and sections are inserted or deleted.
	public struct TableAnimations {
		public struct Actions {
			let insert: UITableView.RowAnimation
			let delete: UITableView.RowAnimation
			let reload: UITableView.RowAnimation
			public static let `default` = Actions(insert: .fade, delete: .fade, reload: .automatic)
			public static let legacy = Actions(insert: .top, delete: .top, reload: .automatic)
			
			public init(insert: UITableView.RowAnimation, delete: UITableView.RowAnimation, reload: UITableView.RowAnimation) {
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
	
	/// Initializes a FunctionalTableData. To configure its view, provide a UITableView after initialization.
	///
	/// - Parameter name: String identifying this instance of FunctionalTableData, useful when several instances are displayed on the same screen. This value also names the queue doing all the rendering work, useful for debugging.
	public init(name: String? = nil) {
		self.name = name ?? "FunctionalTableDataRenderAndDiff"
		unitTesting = NSClassFromString("XCTestCase") != nil
		renderAndDiffQueue = OperationQueue()
		renderAndDiffQueue.name = self.name
		renderAndDiffQueue.maxConcurrentOperationCount = 1
		let data = TableData()
		let cellStyler = CellStyler(data: data)
		self.data = data
		self.cellStyler = cellStyler
		self.dataSource = DataSource(cellStyler: cellStyler)
		self.delegate = Delegate(cellStyler: cellStyler)
	}
	
	/// Returns the cell identified by a key path.
	///
	/// - Parameter keyPath: A key path identifying the cell to look up.
	/// - Returns: A `CellConfigType` instance corresponding to the key path or `nil` if the key path is invalid.
	public func rowForKeyPath(_ keyPath: ItemPath) -> CellConfigType? {
		if let sectionIndex = data.sections.firstIndex(where: { $0.key == keyPath.sectionKey }), let rowIndex = data.sections[sectionIndex].rows.firstIndex(where: { $0.key == keyPath.itemKey }) {
			return data.sections[sectionIndex].rows[rowIndex]
		}
		
		return nil
	}
	
	/// Returns the key path specified by its string presentation.
	///
	/// - Parameter key: String identifier to lookup.
	/// - Returns: A `ItemPath` that matches the key or `nil` if there is no match.
	public func keyPathForRowKey(_ key: String) -> ItemPath? {
		for section in data.sections {
			for row in section where row.key == key {
				return ItemPath(sectionKey: section.key, itemKey: row.key)
			}
		}
		
		return nil
	}
	
	/// Returns the key path of the cell in a given `IndexPath` location.
	///
	/// __Note:__ This method performs an unsafe lookup, make sure that the `IndexPath` exists
	/// before trying to transform it into a `ItemPath`.
	/// - Parameter indexPath: A key path identifying where the key path is located.
	/// - Returns: The key representation of the supplied `IndexPath`.
	public func keyPathForIndexPath(indexPath: IndexPath) -> ItemPath {
		let section = data.sections[indexPath.section]
		let row = section.rows[indexPath.row]
		return ItemPath(sectionKey: section.key, itemKey: row.key)
	}
	
	/// Returns the drawing area for a row identified by key path.
	///
	/// - Parameter keyPath: A key path identifying the cell to look up.
	/// - Returns: A rectangle defining the area in which the table view draws the row or `nil` if the key path is invalid.
	public func rectForKeyPath(_ keyPath: ItemPath) -> CGRect? {
		guard let indexPath = indexPathFromKeyPath(keyPath) else { return nil }
		return tableView?.rectForRow(at: indexPath)
	}
	
	@available(*, deprecated, message: "The `reloadList` argument is no longer available.")
	public func renderAndDiff(_ newSections: [TableSection], keyPath: ItemPath? = nil, reloadList: Bool, animated: Bool = true, animations: TableAnimations = .default, completion: (() -> Void)? = nil) {
		renderAndDiff(newSections, keyPath: keyPath, animated: animated, animations: animations, completion: completion)
	}
	
	/// Populates the table with the specified sections, and asynchronously updates the table view to reflect the cells and sections that have changed.
	///
	/// - Parameters:
	///   - newSections: An array of TableSection instances to populate the table with. These will replace the previous sections and update any cells that have changed between the old and new sections.
	///   - keyPath: The key path identifying which cell to scroll into view after the render occurs.
	///   - animated: `true` to animate the changes to the table cells, or `false` if the `UITableView` should be updated with no animation.
	///   - animations: Type of animation to perform. See `FunctionalTableData.TableAnimations` for more info.
	///   - completion: Callback that will be called on the main thread once the `UITableView` has finished updating and animating any changes.
	@available(*, deprecated, message: "Call `scroll(to:animated:scrollPosition:)` in the completion handler instead.")
	public func renderAndDiff(_ newSections: [TableSection], keyPath: ItemPath?, animated: Bool = true, animations: TableAnimations = .default, completion: (() -> Void)? = nil) {
		renderAndDiff(newSections, animated: animated, animations: animations) { [weak self] in
			if let strongSelf = self, let keyPath = keyPath {
				strongSelf.scroll(to: keyPath)
			}
			completion?()
		}
	}
	
	/// Populates the table with the specified sections, and asynchronously updates the table view to reflect the cells and sections that have changed.
	///
	/// - Parameters:
	///   - newSections: An array of TableSection instances to populate the table with. These will replace the previous sections and update any cells that have changed between the old and new sections.
	///   - animated: `true` to animate the changes to the table cells, or `false` if the `UITableView` should be updated with no animation.
	///   - animations: Type of animation to perform. See `FunctionalTableData.TableAnimations` for more info.
	///   - completion: Callback that will be called on the main thread once the `UITableView` has finished updating and animating any changes.
	public func renderAndDiff(_ newSections: [TableSection], animated: Bool = true, animations: TableAnimations = .default, completion: (() -> Void)? = nil) {
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
						guard let exceptionHandler = FunctionalTableData.exceptionHandler else { return }
						let changes = TableSectionChangeSet()
						let viewFrame = DispatchQueue.main.sync { strongSelf.tableView?.frame ?? .zero }
						let exception = Exception(name: $0.name.rawValue, newSections: newSections, oldSections: strongSelf.data.sections, changes: changes, visible: [], viewFrame: viewFrame, reason: $0.reason, userInfo: $0.userInfo)
						exceptionHandler.handle(exception: exception)
					}
				})
			}
			
			strongSelf.doRenderAndDiff(newSections, animated: animated, animations: animations, completion: completion)
		}
		//cancel waiting operations since only the last state needs to be rendered
		renderAndDiffQueue.operations.lazy.filter { !$0.isExecuting }.forEach { $0.cancel() }
		renderAndDiffQueue.addOperation(blockOperation)
	}
	
	private func doRenderAndDiff(_ newSections: [TableSection], animated: Bool, animations: TableAnimations, completion: (() -> Void)?) {
		guard let tableView = tableView else {
			if let completion = completion {
				DispatchQueue.main.async(execute: completion)
			}
			return
		}
		
		let oldSections = data.sections
		
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
				strongSelf.data.sections = localSections
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
	
	private func applyTableChanges(_ changes: TableSectionChangeSet, localSections: [TableSection], animations: TableAnimations, completion: (() -> Void)?) {
		guard let tableView = tableView else {
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
				cellStyler.update(cellConfig: update.cellConfig, at: update.index, in: tableView)
			}
		}
		
		CATransaction.begin()
		CATransaction.setCompletionBlock {
			completion?()
		}
		
		tableView.beginUpdates()
		// #4629 - There is an issue where on some occasions calling beginUpdates() will cause a heightForRowAtIndexPath() call to be made. If the sections have been changed already we may no longer find the cells
		// in the model causing a crash. To prevent this from happening, only load the new model AFTER beginUpdates() has run
		data.sections = localSections
		applyTableSectionChanges(changes)
		tableView.endUpdates()
		
		// Apply transitions after we have commited section/row changes since transition indexPaths are in post-commit space
		tableView.beginUpdates()
		applyTransitionChanges(changes)
		tableView.endUpdates()
		
		CATransaction.commit()
	}
	
	private func finishRenderAndDiff() {
		renderAndDiffQueue.isSuspended = false
	}
	
	/// Selects a row in the table view identified by a key path.
	///
	/// - Parameters:
	///   - keyPath: A key path identifying a row in the table view.
	///   - animated: `true` if you want to animate the selection, and `false` if the change should be immediate.
	///   - triggerDelegate: `true` to trigger the `tableView:didSelectRowAt:` delegate from `UITableView` or `false` to skip it. Skipping it is the default `UITableView` behavior.
	public func select(keyPath: ItemPath, animated: Bool = true, scrollPosition: UITableView.ScrollPosition = .none, triggerDelegate: Bool = false) {
		guard let tableView = tableView, let indexPath = indexPathFromKeyPath(keyPath) else { return }
		if delegate.tableView(tableView, willSelectRowAt: indexPath) != nil {
			tableView.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
			if triggerDelegate {
				delegate.tableView(tableView, didSelectRowAt: indexPath)
			}
		}
	}
	
	/// Scrolls to the item at the specified key path.
	///
	/// - Parameters:
	///   - keyPath: A key path identifying a row in the table view.
	///   - animated: `true` to animate to the new scroll position, or `false` to scroll immediately.
	///   - scrollPosition: Specifies where the item specified by `keyPath` should be positioned once scrolling finishes.
	public func scroll(to keyPath: ItemPath, animated: Bool = true, scrollPosition: UITableView.ScrollPosition = .bottom) {
		guard let tableView = tableView, let indexPath = indexPathFromKeyPath(keyPath) else { return }
		tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
	}
	
	/// Returns the currently highlighted row
	public var highlightedRow: ItemPath? {
		return cellStyler.highlightedRow
	}
	
	/// Highlights the row at the given ItemPath
	///
	/// - Parameters:
	///   - itemPath: The `ItemPath` to highlight. Pass nil to unhighlight any previously highlighted row.
	///   - animated: `true` to highlight/unhighlight with animations, `false` otherwise.
	public func highlightRow(at itemPath: ItemPath?, animated: Bool) {
		guard let tableView = tableView else { return }
		cellStyler.highlightRow(at: itemPath, animated: animated, in: tableView)
	}
	
	/// - Parameter point: The point in the collection view’s bounds that you want to test.
	/// - Returns: the keypath of the item at the specified point, or `nil` if no item was found at that point.
	public func keyPath(at point: CGPoint) -> ItemPath? {
		guard let indexPath = tableView?.indexPathForRow(at: point) else {
			return nil
		}
		
		return keyPathForIndexPath(indexPath: indexPath)
	}
	
	public func indexPathFromKeyPath(_ keyPath: ItemPath) -> IndexPath? {
		return data.sections.indexPath(from: keyPath)
	}
	
	internal func calculateTableChanges(oldSections: [TableSection], newSections: [TableSection], visibleIndexPaths: [IndexPath]) -> TableSectionChangeSet {
		return TableSectionChangeSet(old: oldSections, new: newSections, visibleIndexPaths: visibleIndexPaths)
	}
	
	public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = tableView?.indexPathForRow(at: location), let cell = tableView?.cellForRow(at: indexPath) else { return nil }
		guard let cellConfig = self[indexPath],
			let viewController = cellConfig.actions.previewingViewControllerAction?(cell, cell.convert(location, from: tableView), previewingContext) else { return nil }
		return viewController
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
