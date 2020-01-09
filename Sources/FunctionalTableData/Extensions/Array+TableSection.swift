//
//  Array+TableSection.swift
//  FunctionalTableData
//
//  Created by Sherry Shao on 2018-06-14.
//  Copyright © 2018 Shopify. All rights reserved.
//

import UIKit

extension Array where Element: TableSectionType {
	func validateKeyUniqueness(senderName: String) {
		let sectionKeys = map { $0.key }
		if Set(sectionKeys).count != count {
			let dupKeys = duplicateKeys()
			let reason = "\(senderName) : Duplicate Section keys"
			let userInfo: [String: Any] = ["Duplicates": dupKeys]
			NSException(name: NSExceptionName.internalInconsistencyException, reason: reason, userInfo: userInfo).raise()
		}
		
		for section in self {
			let rowKeys = section.rows.map { $0.key }
			if Set(rowKeys).count != section.rows.count {
				let dupKeys = section.rows.duplicateKeys()
				let reason = "\(senderName) : Duplicate Section.Row keys"
				let userInfo: [String: Any] = ["Section": section.key, "Duplicates": dupKeys]
				NSException(name: NSExceptionName.internalInconsistencyException, reason: reason, userInfo: userInfo).raise()
			}
		}
	}
}

extension Array where Element: TableSectionType {
	func indexPath(from itemPath: ItemPath) -> IndexPath? {
		if let sectionIndex = self.firstIndex(where: { $0.key == itemPath.sectionKey }), let rowIndex = self[sectionIndex].rows.firstIndex(where: { $0.key == itemPath.rowKey }) {
			return IndexPath(row: rowIndex, section: sectionIndex)
		}
		return nil
	}
	
	func itemPath(from indexPath: IndexPath) -> ItemPath? {
		guard indexPath.section < count else { return nil }
		let section = self[indexPath.section]
		guard indexPath.row < section.rows.count else { return nil }
		let row = section.rows[indexPath.row]
		return ItemPath(sectionKey: section.key, itemKey: row.key)
	}
	
	func itemPaths(from indexPaths: [IndexPath]) -> [ItemPath] {
		return indexPaths.compactMap { itemPath(from: $0) }
	}
	
	subscript(itemPath: ItemPath) -> CellConfigType? {
		guard let indexPath = indexPath(from: itemPath) else { return nil }
		return self[indexPath.section].rows[indexPath.row]
	}
}

private extension Array where Element: Hashable {
	func duplicates() -> [Element] {
		let groups = Dictionary(grouping: self, by: { $0 }).filter { $1.count > 1 }
		return Array(groups.keys)
	}
}

private extension Array where Element: TableSectionType {
	func duplicateKeys() -> [String] {
		return map { $0.key }.duplicates()
	}
}

private extension Array where Element == CellConfigType {
	func duplicateKeys() -> [String] {
		return map { $0.key }.duplicates()
	}
}
