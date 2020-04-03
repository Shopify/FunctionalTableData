//
//  FunctionalCollectionData+UICollectionViewDelegate.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-08.
//  Copyright © 2019 Shopify. All rights reserved.
//

import UIKit

extension FunctionalCollectionData {
	class Delegate: NSObject, UICollectionViewDelegate {
		weak var scrollViewDelegate: UIScrollViewDelegate?
		var backwardsCompatScrollViewDelegate = ScrollViewDelegate()
		
		private let data: TableData
		
		init(data: TableData) {
			self.data = data
		}
		
		public override func responds(to aSelector: Selector!) -> Bool {
			if class_respondsToSelector(type(of: self), aSelector) {
				return true
			} else if let scrollViewDelegate = scrollViewDelegate, scrollViewDelegate.responds(to: aSelector) {
				return true
			} else if backwardsCompatScrollViewDelegate.responds(to: aSelector) {
				return true
			}
			return super.responds(to: aSelector)
		}
		
		public override func forwardingTarget(for aSelector: Selector!) -> Any? {
			if class_respondsToSelector(type(of: self), aSelector) {
				return self
			} else if let scrollViewDelegate = scrollViewDelegate, scrollViewDelegate.responds(to: aSelector) {
				return scrollViewDelegate
			} else if backwardsCompatScrollViewDelegate.responds(to: aSelector) {
				return backwardsCompatScrollViewDelegate
			}
			return super.forwardingTarget(for: aSelector)
		}
		
		public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
			guard let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems, !collectionView.allowsMultipleSelection else { return true }
			return indexPathsForSelectedItems.contains(indexPath) == false
		}
		
		public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
			return data.sections[indexPath]?.actions.selectionAction != nil
		}
		
		public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
			guard let cell = collectionView.cellForItem(at: indexPath) else { return }
			let cellConfig = data.sections[indexPath]
			
			let selectionState = cellConfig?.actions.selectionAction?(cell) ?? .deselected
			if selectionState == .deselected {
				DispatchQueue.main.async {
					collectionView.deselectItem(at: indexPath, animated: true)
				}
			}
		}
		
		public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
			guard let cell = collectionView.cellForItem(at: indexPath) else { return }
			let cellConfig = data.sections[indexPath]
			
			let selectionState = cellConfig?.actions.deselectionAction?(cell) ?? .deselected
			if selectionState == .selected {
				DispatchQueue.main.async {
					collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
				}
			}
		}
		
		public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
			guard indexPath.section < data.sections.count else { return }
			
			if let cellConfig = data.sections[indexPath] {
				cellConfig.actions.visibilityAction?(cell, true)
				return
			}
		}
		
		public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
			if let cellConfig = data.sections[indexPath] {
				cellConfig.actions.visibilityAction?(cell, false)
				return
			}
		}
		
		public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
			return data.sections[indexPath]?.actions.canPerformAction != nil
		}
		
		public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
			return data.sections[indexPath]?.actions.canPerformAction?(action) ?? false
		}
		
		public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
			// required
		}
		
		public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
			guard originalIndexPath.section == proposedIndexPath.section else {
				return originalIndexPath
			}
			
			guard let proposedCell = data.sections[proposedIndexPath], proposedCell.actions.canBeMoved else {
				return originalIndexPath
			}
			
			return proposedIndexPath
		}
		
		@available(iOS 13.0, *)
		public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
			guard data.sections.indices.contains(indexPath.section),
				data.sections[indexPath.section].rows.indices.contains(indexPath.row)
				else { return nil }
			
			let section = data.sections[indexPath.section]
			let row = section.rows[indexPath.row]
			let itemPath = ItemPath(sectionKey: section.key, itemKey: row.key)
			let cellConfig = data.sections[indexPath]
			return cellConfig?.actions.contextMenuConfiguration?.asUIContextMenuConfiguration(with: ItemPathCopyable(itemPath: itemPath))
		}
		
		@available(iOS 13.0, *)
		public func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
			guard let itemPathCopyable = configuration.identifier as? ItemPathCopyable else { return }
			let keyPath = itemPathCopyable.itemPath
			
			guard let sectionIndex = data.sections.firstIndex(where: { $0.key == keyPath.sectionKey }),
				let rowIndex = data.sections[sectionIndex].rows.firstIndex(where: { $0.key == keyPath.itemKey })
				else { return }
			let cellConfig = data.sections[sectionIndex].rows[rowIndex]
			
			animator.addCompletion {
				cellConfig.actions.contextMenuConfiguration?.previewContentCommitter?(animator.previewViewController)
			}
		}
	}
}
