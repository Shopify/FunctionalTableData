//
//  HostCell.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-10-14.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

/// Defines the view, state and layout information of an item inside a TableSection.
/// It relies on you to build UIView subclasses and use those instead of implementing UITableViewCell or UICollectionViewCell subclasses. This has the side effect of building better more reusable view components. This greatly simplifies composition by combining several host-cells into more complex layouts. It also makes equality simpler and more "Swifty" by requiring that anything provided as State only requires that the State object conform to the Equatable protocol. The View portion of the generic only requires it to be a UIView subclass.
public struct HostCell<View, State, Layout>: CellConfigType where View: UIView, State: Equatable, Layout: TableItemLayout {
	public typealias TableViewCellType = TableCell<View, Layout>
	public typealias CollectionViewCellType = CollectionCell<View, Layout>
	
	public let key: String
	public var style: CellStyle?
	public let actions: CellActions
	/// Contains the state information of a cell.
	public let state: State
	/// A function that updates a cell's view to match the current state. It receives two values, the view instance and an optional state instance. The purpose of this function is to update the view to reflect that of the given state. The reason that the state is optional is because cells may move into the reuse queue. When this happens they no longer have a state and the updater function is called giving the opportunity to reset the view to its default value.
	public let cellUpdater: (_ view: View, _ state: State?) -> Void
	
	public init(key: String, style: CellStyle? = nil, actions: CellActions = CellActions(), state: State, cellUpdater: @escaping (_ view: View, _ state: State?) -> Void) {
		self.key = key
		self.style = style
		self.actions = actions
		self.state = state
		self.cellUpdater = cellUpdater
	}
	
	// MARK: - TableItemConfigType
	
	/// Registers the instance of this HostCell for use in creating new table cells.
	///
	/// - Parameter tableView: the `UITableView` to register the cell with.
	public func register(with tableView: UITableView) {
		tableView.registerReusableCell(TableCell<View, Layout>.self)
	}
	
	/// Registers the instance of this HostCell for use in creating new table cells.
	///
	/// - Parameter collectionView: the `UICollectionView` to register the cell with.
	public func register(with collectionView: UICollectionView) {
		collectionView.registerReusableCell(CollectionCell<View, Layout>.self)
	}
	
	/// Returns a reusable `UITableView` cell object for the specified reuse identifier and adds it to the table.
	///
	/// - Parameters:
	///   - tableView: the `UITableView` holding the cells.
	///   - indexPath: The index path specifying the location of the cell.
	/// - Returns: A UITableViewCell object that exists in the reusable-cell queue.
	public func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(TableCell<View, Layout>.self, indexPath: indexPath)
		cell.prepare = { [cellUpdater] view in
			cellUpdater(view, nil)
		}
		return cell
	}
	
	/// Returns a reusable `UICollectionView` cell object for the specified reuse identifier and adds it to the collection.
	///
	/// - Parameters:
	///   - collectionView: the `UICollectionView` holding the cells.
	///   - indexPath: The index path specifying the location of the cell.
	/// - Returns: A UICollectionViewCell object that exists in the reusable-cell queue.
	public func dequeueCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(CollectionCell<View, Layout>.self, indexPath: indexPath)
		cell.prepare = { [cellUpdater] view in
			cellUpdater(view, nil)
		}
		return cell
	}
	
	// MARK: - CellConfigType
	
	public func update(cell: UITableViewCell, in tableView: UITableView) {
		guard let cell = cell as? TableViewCellType else { return }
		
		cellUpdater(cell.view, state)
		// Only layout cells that aren't in the reuse pool
		if cell.superview != nil && !cell.isHidden {
			UIView.performWithoutAnimation {
				cell.layoutIfNeeded()
			}
		}
	}
	
	public func update(cell: UICollectionViewCell, in collectionView: UICollectionView) {
		guard let cell = cell as? CollectionViewCellType else { return }
		cellUpdater(cell.view, state)
	}
	
	public func isEqual(_ other: CellConfigType) -> Bool {
		if let other = other as? HostCell<View, State, Layout> {
			return state == other.state
		}
		return false
	}
	
	public func debugInfo() -> [String: Any] {
		let debugInfo: [String: Any] = ["key": key, "type": String(describing: type(of: self))]
		return debugInfo
	}
}

extension HostCell {
	public init<T: RawRepresentable>(key: T, style: CellStyle? = nil, actions: CellActions = CellActions(), state: State, cellUpdater: @escaping (_ view: View, _ state: State?) -> Void) where T.RawValue == String {
		self.init(key: key.rawValue, style: style, actions: actions, state: state, cellUpdater: cellUpdater)
	}
}
