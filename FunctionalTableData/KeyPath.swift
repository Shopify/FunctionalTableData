//
//  KeyPath.swift
//  FunctionalTableData
//
//  Created by Kevin Barnes on 2018-10-29.
//  Copyright © 2018 Shopify. All rights reserved.
//

import Foundation

/// Represents the unique path to a given item in the `FunctionalTableData`.
///
/// Think of it as a readable implementation of `IndexPath`, that can be used to locate a given cell
/// or `TableSection` in the data set.
public struct KeyPath: Hashable {
	/// Unique identifier for a section.
	public let sectionKey: AnyHashable
	/// Unique identifier for an item inside a section.
	public let rowKey: AnyHashable
	
	public init(sectionKey: AnyHashable, rowKey: AnyHashable) {
		self.sectionKey = sectionKey
		self.rowKey = rowKey
	}
}

public typealias LegacyKeyPathToNewKeyPathBridge = KeyPath

extension FunctionalTableData {
	public typealias KeyPath = LegacyKeyPathToNewKeyPathBridge
}

extension FunctionalCollectionData {
	public typealias KeyPath = LegacyKeyPathToNewKeyPathBridge
}
