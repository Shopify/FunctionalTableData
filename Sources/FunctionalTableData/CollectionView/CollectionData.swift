//
//  CollectionData.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-10-04.
//  Copyright © 2021 Shopify. All rights reserved.

import Foundation

class CollectionData {
	var header: CollectionSupplementaryItemConfig?
	var footer: CollectionSupplementaryItemConfig?
	var sections: [CollectionSection] = []

	subscript(key: IndexPath) -> CellConfigType? {
		/// Accessing `.section` or `.row` from an `IndexPath` causes a crash
		/// if it doesn't have exactly two elements.
		///
		/// This can occur with the following steps:
		///
		/// - Enable Voice Control from the iOS Settings app
		///
		/// - Navigate to a view controller that uses `FunctionalTableData`.
		/// The `tableView(_:leadingSwipeActionsConfigurationForRowAt:)` delegate
		/// method gets called with an empty index path.
		///
		/// - The FunctionalTableData implementation then calls this subscript
		/// with an empty index path.
		guard key.count == 2, key.section < sections.count else { return nil }
		let item = key.item
		let section: CollectionSection = sections[key.section]
		return (item < section.items.count) ? section.items[item] : nil
	}
}
