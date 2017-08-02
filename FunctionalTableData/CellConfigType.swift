//
//  CellConfigType.swift
//  FunctionalTableData
//
//  Created by Tom Burns on 2016-02-20.
//  Copyright © 2016 Shopify. All rights reserved.
//

import Foundation

/// A type that provides the information required by `FunctionalTableData` to generate cells.
///
/// The `key` property should be a unique String for the section that the item is contained in. It should also be representative of the item and not just a random value or UUID. This is because on an update pass the `key` is used to determine if an item has been added, moved, or removed from the data set. Using a stable value means that this can correctly be determined.
///
/// The `isEqual` function is used to determine if two CellConfigType’s have matching keys and they represent the same data. This allows the system to update the views state directly when something has changed instead of forcing a reload of the entire cell all the time.
///
/// When two items have matching `key` values but the `isEqual` call between old and new returns false the `update` function is called. It is the responsibility of this function to update the cell, and any subviews of the cell, to reflect the state.
public protocol CellConfigType: TableItemConfigType {
	/// Unique identifier for the cell.
	var key: String { get }
	/// Indicates a cell style. See `CellStyle` for more information.
	var style: CellStyle? { get set }
	/// Indicates all the possible actions a cell can perform. See `CellActions` for more information.
	var actions: CellActions { get }
	
	/// Update the view state of a `UITableViewCell`. It is up to implementors of the protocol to determine what this means.
	///
	/// - Parameters:
	///   - cell: A cell view that was dequeued from the `UITableView`.
	///   - tableView: The `UITableView` object holding this cell.
	func update(cell: UITableViewCell, in tableView: UITableView)
	/// Compares two cells for equality. Cells will be considered equal if they are of the same type and their states also compare equal.
	///
	/// Cell equality is used during rendering to determine when an existing cell's view needs to be updated with new data.
	///
	/// - Parameter other: the value to compare against.
	/// - Returns: `true` when both values are the same, `false` otherwise.
	func isEqual(_ other: CellConfigType) -> Bool
	func debugInfo() -> [String: Any]
}
