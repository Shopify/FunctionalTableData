//
//  Array+TableSection.swift
//  FunctionalTableData
//
//  Created by Sherry Shao on 2018-06-14.
//  Copyright © 2018 Shopify. All rights reserved.
//

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

private extension Array where Element: Hashable {
	func duplicates() -> Set<Element> {
		var dups: Set<Element> = []
		var uniques: Set<Element> = []
		forEach {
			if uniques.contains($0) {
				dups.insert($0)
			} else {
				uniques.insert($0)
			}
		}
		return dups
	}
}

private extension Array where Element: TableSectionType {
	func duplicateKeys() -> Set<String> {
		return map { $0.key }.duplicates()
	}
}

private extension Array where Element == CellConfigType {
	func duplicateKeys() -> Set<String> {
		return map { $0.key }.duplicates()
	}
}
