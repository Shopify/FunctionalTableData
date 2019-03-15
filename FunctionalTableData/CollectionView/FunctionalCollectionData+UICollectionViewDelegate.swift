//
//  FunctionalCollectionData+UICollectionViewDelegate.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-08.
//  Copyright © 2019 Shopify. All rights reserved.
//

import Foundation

extension FunctionalCollectionData {
	class Delegate: NSObject, UICollectionViewDelegate {
		var sections: [TableSection] = []
		
		weak var scrollViewDelegate: UIScrollViewDelegate?
		var backwardsCompatScrollViewDelegate = ScrollViewDelegate()
		
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
			return sections[indexPath]?.actions.selectionAction != nil
		}
		
		public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
			guard let cell = collectionView.cellForItem(at: indexPath) else { return }
			let cellConfig = sections[indexPath]
			
			let selectionState = cellConfig?.actions.selectionAction?(cell) ?? .deselected
			if selectionState == .deselected {
				DispatchQueue.main.async {
					collectionView.deselectItem(at: indexPath, animated: true)
				}
			}
		}
		
		public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
			guard let cell = collectionView.cellForItem(at: indexPath) else { return }
			let cellConfig = sections[indexPath]
			
			let selectionState = cellConfig?.actions.deselectionAction?(cell) ?? .deselected
			if selectionState == .selected {
				DispatchQueue.main.async {
					collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
				}
			}
		}
		
		public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
			guard indexPath.section < sections.count else { return }
			
			if let cellConfig = sections[indexPath] {
				cellConfig.actions.visibilityAction?(cell, true)
				return
			}
		}
		
		public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
			if let cellConfig = sections[indexPath] {
				cellConfig.actions.visibilityAction?(cell, false)
				return
			}
		}
		
		public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
			return sections[indexPath]?.actions.canPerformAction != nil
		}
		
		public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
			return sections[indexPath]?.actions.canPerformAction?(action) ?? false
		}
		
		public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
			// required
		}
		
		public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
			return originalIndexPath.section == proposedIndexPath.section ? proposedIndexPath : originalIndexPath
		}
	}
}
