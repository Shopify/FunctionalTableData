//
//  FunctionalCollectionData+UICollectionViewDataSource.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-08.
//  Copyright © 2019 Shopify. All rights reserved.
//

import UIKit

extension FunctionalCollectionData {
	class DataSource: NSObject, UICollectionViewDataSource {
		let data: CollectionData
		
		init(data: CollectionData) {
			self.data = data
		}
		
		public func numberOfSections(in collectionView: UICollectionView) -> Int {
			return data.sections.count
		}
		
		public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return data.sections[section].items.count
		}
		
		public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let sectionData = data.sections[indexPath.section]
			let row = indexPath.item
			let cellConfig = sectionData.items[row]
			let cell = cellConfig.dequeueCell(from: collectionView, at: indexPath)
			let accessibilityIdentifier = ItemPath(sectionKey: sectionData.key, itemKey: cellConfig.key).description
			cellConfig.accessibility.with(defaultIdentifier: accessibilityIdentifier).apply(to: cell)
			cellConfig.update(cell: cell, in: collectionView)
			let style = cellConfig.style ?? CellStyle()
			style.configure(cell: cell, at: indexPath, in: collectionView)
			sectionData.prepareCell(cell, in: collectionView, for: indexPath)
			return cell
		}
		
		public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
			let kind = ReusableKind(kind)
			// we need to check the global header/footer first, because the collectionView will request them without a "valid" indexPath.
			// there's a crashing exception or an assertion failure if we have an indexPath with only one index and call IndexPath.section
			if let header = data.header, kind == header.kind {
				let headerView = header.dequeueView(collectionView: collectionView, indexPath: indexPath)
				header.update(headerView, collectionView: collectionView, forIndex: -1)
				return headerView
			}
			if let footer = data.footer, kind == footer.kind {
				let footerView = footer.dequeueView(collectionView: collectionView, indexPath: indexPath)
				footer.update(footerView, collectionView: collectionView, forIndex: -1)
				return footerView
			}
			let sectionData = data.sections[indexPath.section]
			guard let reusableKindConfig = sectionData.supplementaryConfig(ofKind: kind) else {
				fatalError("We MUST return a non-null UICollectionReusableView that was previously registered with the collectionView. There's a crash otherwise. If you're seeing this error, check to see if you have registered a view of kind \(kind).")
			}
			let reusableView = reusableKindConfig.dequeueView(collectionView: collectionView, indexPath: indexPath)
			reusableKindConfig.update(reusableView, collectionView: collectionView, forIndex: indexPath.item)
			return reusableView
		}
		
		public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
			// Should only ever be moving within section
			assert(sourceIndexPath.section == destinationIndexPath.section)
			
			// Update internal state to match move
			let cell = data.sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.item)
			data.sections[destinationIndexPath.section].items.insert(cell, at: destinationIndexPath.item)
			
			data.sections[sourceIndexPath.section].didMoveRow?(sourceIndexPath.item, destinationIndexPath.item)
		}
		
		public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
			return data[indexPath]?.actions.canBeMoved ?? false
		}
	}
}
