//
//  DragDelegate.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-10-24.
//  Copyright © 2019 Shopify. All rights reserved.
//

import UIKit

class DragDelegate: NSObject {
	let data: TableData
	
	init(data: TableData) {
		self.data = data
		super.init()
	}
}

extension DragDelegate: UICollectionViewDragDelegate {
	@available(iOSApplicationExtension 11.0, *)
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let cellConfig = data.sections[indexPath] else { return [] }
		guard let dragAction = cellConfig.actions.dragAction else { return [] }
		guard let provider = dragAction.provider() else { return [] }
		let dragItem = UIDragItem(itemProvider: provider)
		return [dragItem]
	}
}

class DropDelegate: NSObject {
	let data: TableData
	
	init(data: TableData) {
		self.data = data
		super.init()
	}
}

@available(iOSApplicationExtension 11.0, *)
extension DropDelegate: UICollectionViewDropDelegate {
	func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
		var destinationIndex: Int = data.sections.startIndex
		var position: ItemPath?
		if let indexPath = coordinator.destinationIndexPath {
			position = data.itemPath(from: indexPath)
			destinationIndex = indexPath.section
		}
		let dragIndexPaths = coordinator.items.compactMap { $0.sourceIndexPath }
		let dragItemPaths = dragIndexPaths.map { data.itemPath(from: $0) }
		let items = coordinator.items.map { $0.dragItem.itemProvider }
		
		let request = SectionActions.Move.Request(items: items, position: position, sourceLocations: dragItemPaths)
		
		data.sections[destinationIndex].actions?.move?.didMove(request)
	}
	
	func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
		return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
	}
}
