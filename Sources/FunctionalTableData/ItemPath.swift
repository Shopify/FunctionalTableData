//
//  ItemPath.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-28.
//  Copyright © 2019 Shopify. All rights reserved.
//

import Foundation

/// Represents the unique path to a given item in the `FunctionalData`.
///
/// Think of it as a readable implementation of `IndexPath`, that can be used to locate a given cell
/// or `TableSection` in the data set.
public struct ItemPath: Hashable, CustomStringConvertible {
	/// Unique identifier for a section.
	public let sectionKey: String
	/// Unique identifier for an item inside a section.
	public let itemKey: String
	
	public init(sectionKey: String, itemKey: String) {
		self.sectionKey = sectionKey
		self.itemKey = itemKey
	}
	
	public var description: String {
		return "\(sectionKey).\(itemKey)"
	}
}

// MARK: - Compatibility

public extension ItemPath {
	init(sectionKey: String, rowKey: String) {
		self.init(sectionKey: sectionKey, itemKey: rowKey)
	}

	var rowKey: String {
		return itemKey
	}
}
