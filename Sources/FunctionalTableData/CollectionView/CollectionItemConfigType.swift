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

extension CollectionItemConfigType {
	public func dequeueCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
		return collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.reuseIdentifier, for: indexPath)
	}
}
