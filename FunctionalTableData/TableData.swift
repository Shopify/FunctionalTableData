//
//  TableData.swift
//  FunctionalTableData
//
//  Created by Pierre Oleo on 2019-04-29.
//  Copyright © 2019 Shopify. All rights reserved.
//

import Foundation

class TableData {
	var sections: [TableSection] = []
	
	/// Returns the item path of the cell in a given `IndexPath` location.
	///
	/// - Note: This method performs an unsafe lookup, make sure that the `IndexPath` exists
	/// before trying to transform it into a `ItemPath`.
	/// - Parameter indexPath: A key path identifying where the key path is located.
	/// - Returns: The key representation of the supplied `IndexPath`.
	func itemPath(from indexPath: IndexPath) -> ItemPath {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]
		return ItemPath(sectionKey: section.key, itemKey: row.key)
	}
}
