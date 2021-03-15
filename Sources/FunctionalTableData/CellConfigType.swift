//
//  CellConfigType.swift
//  FunctionalTableData
//
//  Created by Tom Burns on 2016-02-20.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

/// A type that provides the information required by `FunctionalTableData` to generate cells.
///
/// The `key` property should be a unique String for the section that the item is contained in. It should also be representative of the item and not just a random value or UUID. This is because on an update pass the `key` is used to determine if an item has been added, moved, or removed from the data set. Using a stable value means that this can correctly be determined.
///
/// The `isEqual` function is used to determine if two CellConfigType’s have matching keys and they represent the same data. This allows the system to update the views state directly when something has changed instead of forcing a reload of the entire cell all the time.
///
/// When two items have matching `key` values but the `isEqual` call between old and new returns false the `update` function is called. It is the responsibility of this function to update the cell, and any subviews of the cell, to reflect the state.
public protocol CellConfigType: TableItemConfigType, CollectionItemConfigType {
	/// Unique identifier for the cell.
	var key: String { get }
	/// Indicates a cell style. See `CellStyle` for more information.
	var style: CellStyle? { get set }
	/// Indicates all the possible actions a cell can perform. See `CellActions` for more information.
	var actions: CellActions { get set }
	
	var accessibility: Accessibility { get set }
	
	/// Update the view state of a `UITableViewCell`. It is up to implementors of the protocol to determine what this means.
	///
	/// - Parameters:
	///   - cell: A cell view that was dequeued from the `UITableView`.
	///   - tableView: The `UITableView` object holding this cell.
	func update(cell: UITableViewCell, in tableView: UITableView)
	
	/// Update the view state of a `UICollectionViewCell`. It is up to implementors of the protocol to determine what this means.
	///
	/// - Parameters:
	///   - cell: A cell view that was dequeued from the `UICollectionView`.
	///   - collectionView: The `UICollectionView` object holding this cell.
	func update(cell: UICollectionViewCell, in collectionView: UICollectionView)
	
	/// Compares two cells for equality. Cells will be considered equal if they are of the same type and their states also compare equal.
	///
	/// Cell equality is used during rendering to determine when an existing cell's view needs to be updated with new data.
	///
	/// - Parameter other: the value to compare against.
	/// - Returns: `true` when both values are the same, `false` otherwise.
	func isEqual(_ other: CellConfigType) -> Bool
	func debugInfo() -> [String: Any]
	
	/// Compares self against another `CellConfigType` to determine if they should be counted as being the same type.
	///
	/// - note: This should almost never need to be implemented. The default version of it, provided as a protocol extension,
	///   does the expected thing (and compares `type(of:)` to `type(of:)`. This is intended for test cases to be able to override.
	///
	/// - Parameter other: The other `CellConfigType` to compare against.
	/// - Returns: `true` if the same type, `false` otherwise
	func isSameKind(as other: CellConfigType) -> Bool
}

public extension CellConfigType {
	func isSameKind(as other: CellConfigType) -> Bool {
		return type(of: self) == type(of: other)
	}
}

public struct AnyCellConfigType: CellConfigType, Hashable {

	public static func ==(lhs: AnyCellConfigType, rhs: AnyCellConfigType) -> Bool {
		return lhs.sectionKey == rhs.sectionKey && lhs.key == rhs.key 
	}
	
	public var key: String {
		return base.key
	}
	
	public var style: CellStyle? {
		get { return base.style }
		set { base.style = newValue }
	}
	
	public var actions: CellActions {
		get { return base.actions }
		set { base.actions = newValue }
	}
	
	public var accessibility: Accessibility {
		get { return base.accessibility }
		set { base.accessibility = newValue }
	}
	
	public var base: CellConfigType
	private let sectionKey: String
	
	init(_ base: CellConfigType, sectionKey: String) {
		self.base = base
		self.sectionKey = sectionKey
	}
	
	public init(_ base: CellConfigType) {
		self.init(base, sectionKey: "")
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(key)
		hasher.combine(sectionKey)
		hasher.combine(style)
	}
	
	public func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		return base.dequeueCell(from: tableView, at: indexPath)
	}
	
	public func update(cell: UITableViewCell, in tableView: UITableView) {
		base.update(cell: cell, in: tableView)
	}
	
	public func update(cell: UICollectionViewCell, in collectionView: UICollectionView) {
		base.update(cell: cell, in: collectionView)
	}
	
	public func isEqual(_ other: CellConfigType) -> Bool {
		guard let other = other as? AnyCellConfigType else { return false }
		return sectionKey == other.sectionKey && key == other.key
	}
	
	public func isSameKind(as other: CellConfigType) -> Bool {
		return base.isSameKind(as: other)
	}
	
	public func debugInfo() -> [String : Any] {
		return base.debugInfo()
	}
	
	public func register(with tableView: UITableView) {
		base.register(with: tableView)
	}
	
	public func register(with collectionView: UICollectionView) {
		base.register(with: collectionView)
	}
	
	
}
