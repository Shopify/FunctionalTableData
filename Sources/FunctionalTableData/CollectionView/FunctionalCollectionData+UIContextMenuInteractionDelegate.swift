//
//  FunctionalCollectionData+UIContextMenuInteractionDelegate.swift
//  FunctionalTableData
//
//  Created by Drake Morin on 2020-03-09.
//  Copyright © 2020 Shopify. All rights reserved.
//

import UIKit

extension FunctionalCollectionData {
	@available(iOS 13.0, *)
	class CollectionViewContextMenuDelegate: Delegate {
		private let data: TableData
		
		override init(data: TableData) {
			self.data = data
			super.init(data: data)
		}
		
		public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
			let cellConfig = data.sections[indexPath]
			return cellConfig?.actions.contextMenuConfiguration?.asUIContextMenuConfiguration(with: indexPath)
		}
		
		public func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
			guard let indexPath = configuration.identifier as? IndexPath else { return }
			let cellConfig = data.sections[indexPath]
			animator.addCompletion {
				cellConfig?.actions.contextMenuConfiguration?.previewContentCommitter?(animator.previewViewController)
			}
		}
	}
}
