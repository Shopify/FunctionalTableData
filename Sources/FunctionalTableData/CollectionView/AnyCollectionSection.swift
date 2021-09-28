//
//  AnyCollectionSection.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-10-28.
//

import UIKit

struct AnyCollectionSection: Hashable {
	public static func ==(lhs: AnyCollectionSection, rhs: AnyCollectionSection) -> Bool {
		return lhs.key == rhs.key
	}

	private var impl: CollectionSection
	
	public var key: String { impl.key }
	public var items: [HashableCellConfigType]
	public var supplementaries: [CollectionSupplementaryItemConfig] {
		get { impl.supplementaries }
		set { impl.supplementaries = newValue }
	}
			
	public init(_ section: CollectionSection) {
		items = section.items.map { AnyHashableConfig($0, sectionKey: section.key) }
		impl = section
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(key)
	}
	
	/// Callback executed when a item is manually moved by the user. It specifies the before and after index position.
	public var didMoveRow: ((_ from: Int, _ to: Int) -> Void)? { impl.didMoveRow }
	
	public func prepareCell(_ cell: UICollectionViewCell, in collectionView: UICollectionView, for indexPath: IndexPath) {
		impl.prepareCell(cell, in: collectionView, for: indexPath)
	}
}
