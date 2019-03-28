//
//  FunctionalCollectionData.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-09-16.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import Foundation
import UIKit

/// A renderer for `UICollectionView`.
///
/// By providing a complete description of your view state using an array of `TableSection`. `FunctionalCollectionData` compares it with the previous render call to insert, update, and remove everything that have changed. This massively simplifies state management of complex UI.
public class FunctionalCollectionData {
	/// Specifies the desired exception handling behaviour.
	public static var exceptionHandler: FunctionalTableDataExceptionHandler?
	
	public typealias KeyPath = ItemPath
	
	private func dumpDebugInfoForChanges(_ changes: TableSectionChangeSet, previousSections: [TableSection], visibleIndexPaths: [IndexPath], exceptionReason: String?, exceptionUserInfo: [AnyHashable: Any]?) {
		guard let exceptionHandler = FunctionalTableData.exceptionHandler else { return }
		let exception = FunctionalTableData.Exception(name: name, newSections: sections, oldSections: previousSections, changes: changes, visible: visibleIndexPaths, viewFrame: collectionView?.frame ?? .zero, reason: exceptionReason, userInfo: exceptionUserInfo)
		exceptionHandler.handle(exception: exception)
	}
	
	private var sections: [TableSection] = [] {
		didSet {
			dataSource.sections = sections
			delegate.sections = sections
		}
	}
	private static let reloadEntireTableThreshold = 20
	
	private let renderAndDiffQueue: OperationQueue
	private let name: String
	
	let dataSource = DataSource()
	let delegate = Delegate()
	
	/// Enclosing `UICollectionView` that presents all the `TableSection` data.
	///
	/// `FunctionalCollectionData` will take care of setting its own `UICollectionViewDelegate` and
	/// `UICollectionViewDataSource` and manage all the internals of the `UICollectionView` on its own.
	public var collectionView: UICollectionView? {
		didSet {
			guard let collectionView = collectionView else { return }
			collectionView.dataSource = dataSource
			collectionView.delegate = delegate
		}
	}
	
	public subscript(indexPath: IndexPath) -> CellConfigType? {
		return sections[indexPath]
	}
	
	/// An object to receive various [UIScrollViewDelegate](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate) related events
	public weak var scrollViewDelegate: UIScrollViewDelegate? {
		get {
			return delegate.scrollViewDelegate
		}
		set {
			delegate.scrollViewDelegate = newValue
			
			// Reset the delegate, this triggers UITableView and UIScrollView to re-cache their available delegate methods
			collectionView?.delegate = nil
			collectionView?.delegate = delegate
		}
	}
	
	private let unitTesting: Bool
	
	/// A Boolean value that returns `true` when a `renderAndDiff` pass is currently running.
	public var isRendering: Bool {
		return renderAndDiffQueue.isSuspended
	}
	
	/// Initializes a FunctionalCollectionData. To configure its view, provide a UICollectionView after initialization.
	///
	/// - Parameter name: String identifying this instance of FunctionalCollectionData, useful when several instances are displayed on the same screen. This also value names the queue doing all the rendering work, useful for debugging.
	public init(name: String? = nil) {
		self.name = name ?? "FunctionalCollectionDataRenderAndDiff"
		unitTesting = NSClassFromString("XCTestCase") != nil
		renderAndDiffQueue = OperationQueue()
		renderAndDiffQueue.name = self.name
		renderAndDiffQueue.maxConcurrentOperationCount = 1
	}
	
	deinit {
		collectionView?.delegate = nil
	}
	
	/// Returns the cell identified by a key path.
	///
	/// - Parameter keyPath: A key path identifying the cell to look up.
	/// - Returns: A `CellConfigType` instance corresponding to the key path or `nil` if the key path is invalid.
	public func rowForKeyPath(_ keyPath: KeyPath) -> CellConfigType? {
		if let sectionIndex = sections.index(where: { $0.key == keyPath.sectionKey }), let rowIndex = sections[sectionIndex].rows.index(where: { $0.key == keyPath.itemKey }) {
			return sections[sectionIndex].rows[rowIndex]
		}
		
		return nil
	}
	
	/// Returns the key path specified by its string presentation.
	///
	/// - Parameter key: String identifier to lookup.
	/// - Returns: A `ItemPath` that matches the key or `nil` if there is no match.
	public func keyPathForRowKey(_ key: String) -> ItemPath? {
		for section in sections {
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
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.item]
		return ItemPath(sectionKey: section.key, itemKey: row.key)
	}
	
	/// Populates the collection with the specified sections, and asynchronously updates the collection view to reflect the cells and sections that have changed.
	///
	/// - Parameters:
	///   - newSections: An array of TableSection instances to populate the collection with. These will replace the previous sections and update any cells that have changed between the old and new sections.
	///   - keyPath: The key path identifying which cell to scroll into view after the render occurs.
	///   - animated: `true` to animate the changes to the collection cells, or `false` if the `UICollectionView` should be updated with no animation.
	///   - completion: Callback that will be called on the main thread once the `UICollectionView` has finished updating and animating any changes.
	@available(*, deprecated, message: "Call `scroll(to:animated:scrollPosition:)` in the completion handler instead.")
	public func renderAndDiff(_ newSections: [TableSection], keyPath: ItemPath?, animated: Bool = true, completion: (() -> Void)? = nil) {
		renderAndDiff(newSections, animated: animated) { [weak self] in
			if let strongSelf = self, let keyPath = keyPath {
				strongSelf.scroll(to: keyPath)
			}
			completion?()
		}
	}
	
	/// Populates the collection with the specified sections, and asynchronously updates the collection view to reflect the cells and sections that have changed.
	///
	/// - Parameters:
	///   - newSections: An array of TableSection instances to populate the collection with. These will replace the previous sections and update any cells that have changed between the old and new sections.
	///   - animated: `true` to animate the changes to the collection cells, or `false` if the `UICollectionView` should be updated with no animation.
	///   - completion: Callback that will be called on the main thread once the `UICollectionView` has finished updating and animating any changes.
	public func renderAndDiff(_ newSections: [TableSection], animated: Bool = true, completion: (() -> Void)? = nil) {
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
						let viewFrame = DispatchQueue.main.sync { strongSelf.collectionView?.frame ?? .zero }
						let exception = FunctionalTableData.Exception(name: $0.name.rawValue, newSections: newSections, oldSections: strongSelf.sections, changes: changes, visible: [], viewFrame: viewFrame, reason: $0.reason, userInfo: $0.userInfo)
						exceptionHandler.handle(exception: exception)
					}
				})
			}
			
			strongSelf.doRenderAndDiff(newSections, animated: animated, completion: completion)
		}
		renderAndDiffQueue.addOperation(blockOperation)
	}
	
	private func doRenderAndDiff(_ newSections: [TableSection], animated: Bool, completion: (() -> Void)?) {
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
				return $0.item < section.rows.count
			}
		}
		
		let localSections = newSections.filter { $0.rows.count > 0 }
		let changes = calculateTableChanges(oldSections: oldSections, newSections: localSections, visibleIndexPaths: visibleIndexPaths)
		
		// Use dispatch_sync because the collection updates have to be processed before this function returns
		// or another queued renderAndDiff could get the incorrect state to diff against.
		DispatchQueue.main.sync { [weak self] in
			guard let strongSelf = self else {
				completion?()
				return
			}
			
			strongSelf.renderAndDiffQueue.isSuspended = true
			collectionView.registerCellsForSections(localSections)
			if oldSections.isEmpty || changes.count > FunctionalCollectionData.reloadEntireTableThreshold || collectionView.isDecelerating || !animated {
				
				strongSelf.sections = localSections
				
				collectionView.reloadData()
				strongSelf.finishRenderAndDiff()
				completion?()
			} else {
				if strongSelf.unitTesting {
					strongSelf.applyTableChanges(changes, localSections: localSections, completion: {
						strongSelf.finishRenderAndDiff()
						completion?()
					})
				} else {
					NSException.catchAndRethrow({
						strongSelf.applyTableChanges(changes, localSections: localSections, completion: {
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
	
	private func applyTableChanges(_ changes: TableSectionChangeSet, localSections: [TableSection], completion: (() -> Void)?) {
		guard let collectionView = collectionView else {
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
		
		func applyTransitionChanges(_ changes: TableSectionChangeSet) {
			for update in changes.updates {
				if let cell = collectionView.cellForItem(at: update.index) {
					update.cellConfig.update(cell: cell, in: collectionView)
					
					let section = sections[update.index.section]
					let style = section.mergedStyle(for: update.index.item)
					style.configure(cell: cell, in: collectionView)
				}
			}
		}
		
		collectionView.performBatchUpdates({
			sections = localSections
			applyTableSectionChanges(changes)
		}) { finished in
			applyTransitionChanges(changes)
			completion?()
		}
	}
	
	private func finishRenderAndDiff() {
		renderAndDiffQueue.isSuspended = false
	}
	
	/// Selects a row in the collection view identified by a key path.
	///
	/// - Parameters:
	///   - keyPath: A key path identifying a row in the collection view.
	///   - animated: `true` if you want to animate the selection, and `false` if the change should be immediate.
	///   - scrollPosition: An option that specifies where the item should be positioned when scrolling finishes.
	///   - triggerDelegate: `true` to trigger the `collection:didSelectItemAt:` delegate from `UICollectionView` or `false` to skip it. Skipping it is the default `UICollectionView` behavior.
	public func select(keyPath: ItemPath, animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = [], triggerDelegate: Bool = false) {
		guard let collectionView = collectionView, let indexPath = indexPathFromKeyPath(keyPath) else { return }
		
		collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
		if triggerDelegate {
			delegate.collectionView(collectionView, didSelectItemAt: indexPath)
		}
	}
	
	/// Scrolls to the item at the specified key path.
	///
	/// - Parameters:
	///   - keyPath: A key path identifying a row in the collection view.
	///   - animated: `true` to animate to the new scroll position, or `false` to scroll immediately.
	///   - scrollPosition: Specifies where the item specified by `keyPath` should be positioned once scrolling finishes.
	public func scroll(to keyPath: ItemPath, animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = [.bottom, .right]) {
		guard let aCollectionView = collectionView, let indexPath = indexPathFromKeyPath(keyPath) else { return }
		aCollectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
	}
	
	/// - Parameter point: The point in the collection view’s bounds that you want to test.
	/// - Returns: The keypath of the item at the specified point, or `nil` if no item was found at that point.
	public func keyPath(at point: CGPoint) -> ItemPath? {
		guard let indexPath = collectionView?.indexPathForItem(at: point) else {
			return nil
		}
		
		return keyPathForIndexPath(indexPath: indexPath)
	}
	
	/// Returns the IndexPath corresponding to the provided ItemPath.
	///
	/// - Parameter keyPath: The path representing the desired indexPath.
	/// - Returns: The IndexPath of the item at the provided keyPath.
	public func indexPathFromKeyPath(_ keyPath: ItemPath) -> IndexPath? {
		if let sectionIndex = sections.index(where: { $0.key == keyPath.sectionKey }), let rowIndex = sections[sectionIndex].rows.index(where: { $0.key == keyPath.itemKey }) {
			return IndexPath(item: rowIndex, section: sectionIndex)
		}
		
		return nil
	}
	
	internal func calculateTableChanges(oldSections: [TableSection], newSections: [TableSection], visibleIndexPaths: [IndexPath]) -> TableSectionChangeSet {
		return TableSectionChangeSet(old: oldSections, new: newSections, visibleIndexPaths: visibleIndexPaths)
	}
	
	public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
		guard let cellConfig = self[indexPath],
			let viewController = cellConfig.actions.previewingViewControllerAction?(cell, cell.convert(location, from: collectionView), previewingContext) else { return nil }
		return viewController
	}
}

extension UICollectionView {
	fileprivate func registerCellsForSections(_ sections: [TableSection]) {
		for section in sections {
			for cellConfig in section {
				cellConfig.register(with: self)
			}
		}
	}
	
	/// Initiates a layout pass of UICollectionView and its items. Necessary for calculating new
	/// cell heights and animations when the internal state of a cell changes and needs to reflect
	/// them immediately.
	public func render() {
		OperationQueue.main.addOperation { [weak self] in
			self?.performBatchUpdates(nil, completion: nil)
		}
	}
	
	/// Deselects the previously selected row, with an option to animate the deselection.
	///
	/// - Parameter animated: `true` to animate the deselection, or `false` if the change should be immediate.
	public func deselectLastSelectedItem(animated: Bool) {
		if let indexPathForSelectedItem = self.indexPathsForSelectedItems?.last {
			deselectItem(at: indexPathForSelectedItem, animated: animated)
		}
	}
	
	/// Find the `IndexPath` for a particular view. Returns `nil` if the view is not an instance of, or a subview of `UICollectionViewCell`, or if that cell is not a child of `self`
	///
	/// - Parameter view: The view to find the `IndexPath`.
	/// - Returns: The `IndexPath` of the view in the `UICollectionView` or `nil` if it could not be found.
	public func indexPath(for view: UIView) -> IndexPath? {
		guard let cell: UICollectionViewCell = view.typedSuperview() else { return nil }
		return self.indexPath(for: cell)
	}
}
