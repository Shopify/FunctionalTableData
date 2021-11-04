//
//  CollectionItemConfigType.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-09-16.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import UIKit

public protocol CollectionItemConfigType {
	func register(with collectionView: UICollectionView)
	func dequeueCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
}


public protocol CollectionSupplementaryItemConfig {
	var kind: ReusableKind { get }
	
	func register(with collectionView: UICollectionView)
	func dequeueView(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView
	func update(_ view: UICollectionReusableView, collectionView: UICollectionView, forIndex index: Int)
	
	func isEqual(_ other: CollectionSupplementaryItemConfig?) -> Bool
}
