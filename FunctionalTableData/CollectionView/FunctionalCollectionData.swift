//
//  FunctionalCollectionData.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-09-16.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import Foundation
import UIKit

public class FunctionalCollectionData: NSObject {
	/// Specifies the desired exception handling behaviour.
	public static var exceptionHandler: FunctionalTableDataExceptionHandler?
	
	/// Represents the unique path to a given item in the `FunctionalCollectionData`.
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
		let exception = FunctionalTableData.Exception(name: name, newSections: sections, oldSections: previousSections, changes: changes, visible: visibleIndexPaths, viewFrame: collectionView?.frame ?? .zero, reason: exceptionReason)
		exceptionHandler.handle(exception: exception)
	}
	
	private var sections: [TableSection] = []
	private static let reloadEntireTableThreshold = 20
	
	private let renderAndDiffQueue: OperationQueue
	private let name: String
	
	/// Index path for the previously selected row.
	public var indexPathForPreviouslySelectedRow: IndexPath?
	
	public var collectionView: UICollectionView? {
		didSet {
			guard let collectionView = collectionView else { return }
			collectionView.dataSource = self
			collectionView.delegate = self
		}
	}
	
	public subscript(indexPath: IndexPath) -> CellConfigType? {
		return sections[indexPath]
	}
	
	public var scrollViewDidScroll: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewWillBeginDragging: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewWillEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)?
	public var scrollViewDidEndDragging: ((_ scrollView: UIScrollView, _ decelerate: Bool) -> Void)?
	public var scrollViewWillBeginDecelerating: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewDidEndDecelerating: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewDidChangeContentSize: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewDidEndScrollingAnimation: ((_ scrollView: UIScrollView) -> Void)?
	public var scrollViewShouldScrollToTop: ((_ scrollView: UIScrollView) -> Bool)?
	public var scrollViewDidScrollToTop: ((_ scrollView: UIScrollView) -> Void)?
	
	private let unitTesting: Bool
	
	/// A Boolean value that returns `true` when a `renderAndDiff` pass is currently running.
	public var isRendering: Bool {
		return renderAndDiffQueue.isSuspended
	}
	
	public init(name: String? = nil, fileName: String = #file, lineNumber: Int = #line) {
		self.unitTesting = NSClassFromString("XCTestCase") != nil
		self.name = name ?? "FunctionalCollectionDataRenderAndDiff-\((fileName as NSString).lastPathComponent):\(lineNumber)"
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
		let row = section.rows[indexPath.item]
		return KeyPath(sectionKey: section.key, rowKey: row.key)
	}
	
	private func sectionForKey(key: String) -> TableSection? {
		for section in sections {
			if section.key == key {
				return section
			}
		}
		
		return nil
	}
	
	/// Populates the collection with the specified sections, and asynchronously updates the collection view to reflect the cells and sections that have changed.
	///
	/// - Parameters:
	///   - newSections: An array of TableSection instances to populate the collection with. These will replace the previous sections and update any cells that have changed between the old and new sections.
	///   - keyPath: The key path identifying which cell to scroll into view after the render occurs.
	///   - animated: `true` to animate the changes to the collection cells, or `false` if the `UICollectionView` should be updated with no animation.
	///   - completion: Callback that will be called on the main thread once the `UICollectionView` has finished updating and animating any changes.
	@available(*, deprecated, message: "Call `scroll(to:animated:scrollPosition:)` in the completion handler instead.")
	public func renderAndDiff(_ newSections: [TableSection], keyPath: KeyPath?, animated: Bool = true, completion: (() -> Void)? = nil) {
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
			
			func validateKeyUniqueness() {
				let sectionKeys = newSections.map { $0.key }
				if Set(sectionKeys).count != newSections.count {
					let reason = "\(strongSelf.name) : Duplicate Section keys"
					let userInfo: [String: Any] = ["Duplicates": sectionKeys]
					NSException(name: NSExceptionName.internalInconsistencyException, reason: reason, userInfo: userInfo).raise()
				}
				
				for section in newSections {
					let rowKeys = section.rows.map { $0.key }
					if Set(rowKeys).count != section.rows.count {
						let reason = "\(strongSelf.name) : Section.Row keys must all be unique"
						let userInfo: [String: Any] = ["Section": section.key, "Duplicates": rowKeys]
						NSException(name: NSExceptionName.internalInconsistencyException, reason: reason, userInfo: userInfo).raise()
					}
				}
			}
			
			if strongSelf.unitTesting {
				validateKeyUniqueness()
			} else {
				NSException.catchAndRethrow({
					validateKeyUniqueness()
				}, failure: {
					if $0.name == NSExceptionName.internalInconsistencyException {
						guard let exceptionHandler = FunctionalTableData.exceptionHandler else { return }
						let changes = TableSectionChangeSet()
						let exception = FunctionalTableData.Exception(name: $0.name.rawValue, newSections: newSections, oldSections: strongSelf.sections, changes: changes, visible: [], viewFrame: strongSelf.collectionView?.frame ?? .zero, reason: $0.reason)
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
							strongSelf.dumpDebugInfoForChanges(changes, previousSections: oldSections, visibleIndexPaths: visibleIndexPaths, exceptionReason: exception.reason)
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
					style?.configure(cell: cell, in: collectionView)
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
	public func select(keyPath: KeyPath, animated: Bool = true, scrollPosition: UICollectionViewScrollPosition = [], triggerDelegate: Bool = false) {
		guard let aCollectionView = collectionView, let indexPath = indexPathFromKeyPath(keyPath) else { return }

		aCollectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
		if triggerDelegate {
			collectionView(aCollectionView, didSelectItemAt: indexPath)
		}
	}
	
	/// Scrolls to the item at the specified key path.
	///
	/// - Parameters:
	///   - keyPath: A key path identifying a row in the collection view.
	///   - animated: `true` to animate to the new scroll position, or `false` to scroll immediately.
	///   - scrollPosition: Specifies where the item specified by `keyPath` should be positioned once scrolling finishes.
	public func scroll(to keyPath: KeyPath, animated: Bool = true, scrollPosition: UICollectionViewScrollPosition = [.bottom, .right]) {
		guard let aCollectionView = collectionView, let indexPath = indexPathFromKeyPath(keyPath) else { return }
		aCollectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
	}
	
	/// - Parameter point: The point in the collection view’s bounds that you want to test.
	/// - Returns: the keypath of the item at the specified point, or `nil` if no item was found at that point.
	public func keyPath(at point: CGPoint) -> KeyPath? {
		guard let indexPath = collectionView?.indexPathForItem(at: point) else {
			return nil
		}
		
		return keyPathForIndexPath(indexPath: indexPath)
	}
	
	public func indexPathFromKeyPath(_ keyPath: KeyPath) -> IndexPath? {
		if let sectionIndex = sections.index(where: { $0.key == keyPath.sectionKey }), let rowIndex = sections[sectionIndex].rows.index(where: { $0.key == keyPath.rowKey }) {
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

extension FunctionalCollectionData: UICollectionViewDataSource {
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sections.count
	}
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return sections[section].rows.count
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let sectionData = sections[indexPath.section]
		let row = indexPath.item
		let cellConfig = sectionData[row]
		let cell = cellConfig.dequeueCell(from: collectionView, at: indexPath)
		
		cellConfig.update(cell: cell, in: collectionView)
		cellConfig.style?.configure(cell: cell, in: collectionView)
		
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		// Should only ever be moving within section
		assert(sourceIndexPath.section == destinationIndexPath.section)
		
		// Update internal state to match move
		let cell = sections[sourceIndexPath.section].rows.remove(at: sourceIndexPath.item)
		sections[destinationIndexPath.section].rows.insert(cell, at: destinationIndexPath.item)
		
		sections[sourceIndexPath.section].didMoveRow?(sourceIndexPath.item, destinationIndexPath.item)
	}
}

extension FunctionalCollectionData: UICollectionViewDelegate {
	public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		guard let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems, !collectionView.allowsMultipleSelection else { return true }
		return indexPathsForSelectedItems.contains(indexPath) == false
	}

	public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		return sections[indexPath]?.actions.selectionAction != nil
	}
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let cell = collectionView.cellForItem(at: indexPath) else { return }
		let cellConfig = sections[indexPath]
		
		let selectionState = cellConfig?.actions.selectionAction?(cell, true) ?? .deselected
		if selectionState == .deselected {
			DispatchQueue.main.async {
				collectionView.deselectItem(at: indexPath, animated: true)
			}
		}
	}

	public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		guard let cell = collectionView.cellForItem(at: indexPath) else { return }
		let cellConfig = sections[indexPath]
		
		let selectionState = cellConfig?.actions.selectionAction?(cell, false) ?? .deselected
		if selectionState == .selected {
			DispatchQueue.main.async {
				collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
			}
		}
	}
	
	public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard indexPath.section < sections.count else { return }
		
		if let cellConfig = sections[indexPath] {
			cellConfig.actions.visibilityAction?(cell, true)
			return
		}
	}
	
	public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cellConfig = sections[indexPath] {
			cellConfig.actions.visibilityAction?(cell, false)
			return
		}
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
		return sections[indexPath]?.actions.canPerformAction != nil
	}
	
	public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		return sections[indexPath]?.actions.canPerformAction?(action) ?? false
	}
	
	public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
		// required
	}
	
	public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return sections[indexPath]?.actions.canBeMoved ?? false
	}
	
	public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
		return originalIndexPath.section == proposedIndexPath.section ? proposedIndexPath : originalIndexPath
	}
	
	// MARK: - UIScrollViewDelegate
	
	/// This is an undocumented optional `UIScrollViewDelegate` method that is not exposed by the public protocol
	/// but will still get called on delegates that implement it. Because it is not publicly exposed,
	/// the Swift 4 compiler will not automatically annotate it as @objc, requiring this manual annotation.
	@objc public func scrollViewDidChangeContentSize(_ scrollView: UIScrollView) {
		scrollViewDidChangeContentSize?(scrollView)
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollViewDidScroll?(scrollView)
	}
	
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		scrollViewWillBeginDragging?(scrollView)
	}
	
	public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		scrollViewWillEndDragging?(scrollView, velocity, targetContentOffset)
	}
	
	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		scrollViewDidEndDragging?(scrollView, decelerate)
	}
	
	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		scrollViewWillBeginDecelerating?(scrollView)
	}
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		scrollViewDidEndDecelerating?(scrollView)
	}
	
	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		scrollViewDidEndScrollingAnimation?(scrollView)
	}
	
	public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		return scrollViewShouldScrollToTop?(scrollView) ?? true
	}
	
	public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
		scrollViewDidScrollToTop?(scrollView)
	}
}
