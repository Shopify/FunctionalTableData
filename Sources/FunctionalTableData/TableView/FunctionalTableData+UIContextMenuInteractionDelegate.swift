//
//  FunctionalTableData+UIContextMenuInteractionDelegate.swift
//  FunctionalTableData
//
//  Created by Drake Morin on 2020-02-27.
//  Copyright © 2020 Shopify. All rights reserved.
//

import UIKit

extension FunctionalTableData {
	@available(iOS 13.0, *)
	class TableViewContextMenuDelegate: Delegate {
		private let data: TableData
		
		override init(cellStyler: CellStyler) {
			self.data = cellStyler.data
			super.init(cellStyler: cellStyler)
		}
		
		public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
			let cellConfig = data.sections[indexPath]
			return cellConfig?.actions.contextMenuConfiguration?.asUIContextMenuConfiguration(with: indexPath)
		}
		
		public func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
			guard let indexPath = configuration.identifier as? IndexPath else { return }
			let cellConfig = data.sections[indexPath]
			animator.addCompletion {
				cellConfig?.actions.contextMenuConfiguration?.previewContentCommitter?(animator.previewViewController)
			}
		}
	}
}
