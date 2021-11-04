//
//  FunctionalCollectionData.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-09-16.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import UIKit

public protocol FunctionalCollectionDataExceptionHandler {
	func handle(exception: FunctionalCollectionData.Exception)
}

protocol FunctionalCollectionDataDiffer {
	var collectionView: UICollectionView? { get set }
	var isRendering: Bool { get }
	func renderAndDiff(_ newSections: [CollectionSection], animated: Bool, completion: (() -> Void)?)
}

/// A renderer for `UICollectionView`.
///
/// By providing a complete description of your view state using an array of `TableSection`. `FunctionalCollectionData` compares it with the previous render call to insert, update, and remove everything that have changed. This massively simplifies state management of complex UI.
public class FunctionalCollectionData {
	/// A type that provides the information about an exception.
	public struct Exception {
		public let name: String
		public let newSections: [CollectionSection]
		public let oldSections: [CollectionSection]
		public let changes: CollectionSectionChangeSet
		public let visible: [IndexPath]
		public let viewFrame: CGRect
		public let reason: String?
		public let userInfo: [AnyHashable: Any]?
	}
	/// Specifies the desired exception handling behaviour.
	public static var exceptionHandler: FunctionalCollectionDataExceptionHandler?
	
	public typealias KeyPath = ItemPath
		
	private let data = CollectionData()
	var sections: [CollectionSection] {
		return data.sections
	}
	static let reloadEntireTableThreshold = 20
	
	private let name: String
	
	let delegate: Delegate
	
	/// Enclosing `UICollectionView` that presents all the `TableSection` data.
	///
	/// `FunctionalCollectionData` will take care of setting its own `UICollectionViewDelegate` and
	/// `UICollectionViewDataSource` and manage all the internals of the `UICollectionView` on its own.
	public var collectionView: UICollectionView? {
		didSet {
			guard let collectionView = collectionView else { return }
			differ.collectionView = collectionView
			collectionView.delegate = delegate
			data.header?.register(with: collectionView)
			data.footer?.register(with: collectionView)
		}
	}
	
	public subscript(indexPath: IndexPath) -> CellConfigType? {
		return sections[indexPath.section].items[indexPath.item]
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
	
	/// A Boolean value that returns `true` when a `renderAndDiff` pass is currently running.
	public var isRendering: Bool { differ.isRendering }
	
	private let diffingStrategy: DiffingStrategy
	
	private lazy var differ: FunctionalCollectionDataDiffer = {
		if #available(iOS 13.0, *), self.diffingStrategy == .diffableDataSource {
			return DiffableDataSourceFunctionalCollectionDataDiffer(name: self.name, data: data)
		}
		return ClassicFunctionalCollectionDataDiffer(name: self.name, data: data)
	}()
	
	/// Initializes a FunctionalCollectionData. To configure its view, provide a UICollectionView after initialization.
	///
	/// - Parameter name: String identifying this instance of FunctionalCollectionData, useful when several instances are displayed on the same screen. This also value names the queue doing all the rendering work, useful for debugging.
	public init(name: String? = nil, diffingStrategy: DiffingStrategy = .classic) {
		self.name = name ?? "FunctionalCollectionDataRenderAndDiff"
		self.diffingStrategy = diffingStrategy
		
		self.delegate = Delegate(data: data)
	}
	
	/// Returns the cell identified by a key path.
	///
	/// - Parameter keyPath: A key path identifying the cell to look up.
	/// - Returns: A `CellConfigType` instance corresponding to the key path or `nil` if the key path is invalid.
	public func rowForKeyPath(_ keyPath: KeyPath) -> CellConfigType? {
		if let sectionIndex = sections.firstIndex(where: { $0.key == keyPath.sectionKey }), let rowIndex = sections[sectionIndex].items.firstIndex(where: { $0.key == keyPath.itemKey }) {
			return sections[sectionIndex].items[rowIndex]
		}
		
		return nil
	}
	
	/// Returns the key path specified by its string presentation.
	///
	/// - Parameter key: String identifier to lookup.
	/// - Returns: A `ItemPath` that matches the key or `nil` if there is no match.
	public func keyPathForRowKey(_ key: String) -> ItemPath? {
		for section in sections {
			for item in section.items where item.key == key {
				return ItemPath(sectionKey: section.key, itemKey: item.key)
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
		let item = section.items[indexPath.item]
		return ItemPath(sectionKey: section.key, itemKey: item.key)
	}
		
	public func registerCollectionHeader(_ config: CollectionSupplementaryItemConfig) {
		data.header = config
		guard let collectionView = collectionView else { return }
		config.register(with: collectionView)
	}
	
	public func registerCollectionFooter(_ config: CollectionSupplementaryItemConfig) {
		data.footer = config
		guard let collectionView = collectionView else { return }
		config.register(with: collectionView)
	}
	
	/// Populates the collection with the specified sections, and asynchronously updates the collection view to reflect the cells and sections that have changed.
	///
	/// - Parameters:
	///   - newSections: An array of TableSection instances to populate the collection with. These will replace the previous sections and update any cells that have changed between the old and new sections.
	///   - animated: `true` to animate the changes to the collection cells, or `false` if the `UICollectionView` should be updated with no animation.
	///   - completion: Callback that will be called on the main thread once the `UICollectionView` has finished updating and animating any changes.
	public func renderAndDiff(_ newSections: [CollectionSection], animated: Bool = true, completion: (() -> Void)? = nil) {
		differ.renderAndDiff(newSections, animated: animated, completion: completion)
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
		if let sectionIndex = sections.firstIndex(where: { $0.key == keyPath.sectionKey }), let rowIndex = sections[sectionIndex].items.firstIndex(where: { $0.key == keyPath.itemKey }) {
			return IndexPath(item: rowIndex, section: sectionIndex)
		}
		
		return nil
	}
	
	/// Returns the drawing area for a row identified by key path.
	///
	/// - Parameter keyPath: A key path identifying the cell to look up.
	/// - Returns: A rectangle defining the area in which the table view draws the row or `nil` if the key path is invalid.
	public func rectForKeyPath(_ keyPath: ItemPath) -> CGRect? {
		guard let indexPath = indexPathFromKeyPath(keyPath) else { return nil }
		guard let layoutAttr = collectionView?.layoutAttributesForItem(at: indexPath) else { return nil }
		return layoutAttr.frame
	}
	
	public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
		guard let cellConfig = self[indexPath],
			let viewController = cellConfig.actions.previewingViewControllerAction?(cell, cell.convert(location, from: collectionView), previewingContext) else { return nil }
		return viewController
	}
}

extension UICollectionView {
	func registerCellsForSections(_ sections: [CollectionSection]) {
		for section in sections {
			for cellConfig in section.items {
				cellConfig.register(with: self)
			}
			for supplementaryConfig in section.supplementaries {
				supplementaryConfig.register(with: self)
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
