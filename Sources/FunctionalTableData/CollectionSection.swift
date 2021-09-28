//
//  CollectionSection.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-10-05.
//  Copyright © 2021 Shopify. All rights reserved.

import UIKit

public typealias CellPreparer = (UICollectionViewCell, UICollectionView, IndexPath) -> Void

public protocol CollectionSection {
	var key: String { get }
	
	var items: [CellConfigType] { get set }
	
	var supplementaries: [CollectionSupplementaryItemConfig] { get set }
	
	/// Callback executed when an item is manually moved by the user. It specifies the before and after index position.
	var didMoveRow: ((_ from: Int, _ to: Int) -> Void)? { get }
	
	func prepareCell(_ cell: UICollectionViewCell, in collectionView: UICollectionView, for indexPath: IndexPath)
}

public protocol HashableCellConfigType: CellConfigType {
	var hashable: AnyHashable { get }
}

public extension CollectionSection {
	func supplementaryConfig(ofKind kind: ReusableKind) -> CollectionSupplementaryItemConfig? {
		return supplementaries.first(where: { $0.kind == kind })
	}
	
	var header: CollectionSupplementaryItemConfig? {
		return supplementaries.first(where: { $0.kind == .header })
	}
	
	var footer: CollectionSupplementaryItemConfig? {
		return supplementaries.first(where: { $0.kind == .footer })
	}
}

public struct SimpleCollectionSection: CollectionSection, Hashable {
	public static func ==(lhs: SimpleCollectionSection, rhs: SimpleCollectionSection) -> Bool {
		return lhs.key == rhs.key
	}
	
	public let key: String
	public var items: [CellConfigType]
	public var supplementaries: [CollectionSupplementaryItemConfig]
	
	public init(key: String,
				items: [CellConfigType],
				supplementaries: [CollectionSupplementaryItemConfig] = [],
				didMoveRow: ((Int, Int) -> Void)? = nil,
				cellPreparer: CellPreparer? = nil) {
		self.key = key
		self.items = items
		self.supplementaries = supplementaries
		self.didMoveRow = didMoveRow
		self.cellPreparer = cellPreparer
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(key)
	}

	/// Callback executed when an item is manually moved by the user. It specifies the before and after index position.
	public let didMoveRow: ((_ from: Int, _ to: Int) -> Void)?
	
	public var cellPreparer: CellPreparer?
	
	public func prepareCell(_ cell: UICollectionViewCell, in collectionView: UICollectionView, for indexPath: IndexPath) {
		cellPreparer?(cell, collectionView, indexPath)
	}
}
