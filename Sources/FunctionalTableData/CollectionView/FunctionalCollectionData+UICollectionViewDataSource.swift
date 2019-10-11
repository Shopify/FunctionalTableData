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
		private let data: TableData
		
		init(data: TableData) {
			self.data = data
		}
		
		public func numberOfSections(in collectionView: UICollectionView) -> Int {
			return data.sections.count
		}
		
		public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return data.sections[section].rows.count
		}
		
		public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let sectionData = data.sections[indexPath.section]
			let row = indexPath.item
			let cellConfig = sectionData[row]
			let cell = cellConfig.dequeueCell(from: collectionView, at: indexPath)
			cell.accessibilityIdentifier = ItemPath(sectionKey: sectionData.key, itemKey: cellConfig.key).description

			cellConfig.update(cell: cell, in: collectionView)
			let style = cellConfig.style ?? CellStyle()
			style.configure(cell: cell, in: collectionView)
			
			return cell
		}
		
		public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
			// Should only ever be moving within section
			assert(sourceIndexPath.section == destinationIndexPath.section)
			
			// Update internal state to match move
			let cell = data.sections[sourceIndexPath.section].rows.remove(at: sourceIndexPath.item)
			data.sections[destinationIndexPath.section].rows.insert(cell, at: destinationIndexPath.item)
			
			data.sections[sourceIndexPath.section].didMoveRow?(sourceIndexPath.item, destinationIndexPath.item)
		}
		
		public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
			return data.sections[indexPath]?.actions.canBeMoved ?? false
		}
	}
}
