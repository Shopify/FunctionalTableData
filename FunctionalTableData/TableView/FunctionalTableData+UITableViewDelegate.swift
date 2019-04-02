//
//  FunctionalTableData+UITableViewDelegate.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-08.
//  Copyright © 2019 Shopify. All rights reserved.
//

import Foundation

extension FunctionalTableData {
	class Delegate: NSObject, UITableViewDelegate {
		var sections: [TableSection] = []
		private var heightAtIndexKeyPath: [ItemPath: CGFloat] = [:]
		private var cellStyler: CellStyler
		
		weak var scrollViewDelegate: UIScrollViewDelegate?
		var backwardsCompatScrollViewDelegate = ScrollViewDelegate()
		
		init(cellStyler: CellStyler) {
			self.cellStyler = cellStyler
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
		
		public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
			guard let header = sections[section].header else {
				// When given a height of zero grouped style UITableView's use their default value instead of zero. By returning CGFloat.min we get around this behavior and force UITableView to end up using a height of zero after all.
				return tableView.style == .grouped ? CGFloat.leastNormalMagnitude : 0
			}
			return header.height
		}
		
		public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
			guard let footer = sections[section].footer else {
				// When given a height of zero grouped style UITableView's use their default value instead of zero. By returning CGFloat.min we get around this behavior and force UITableView to end up using a height of zero after all.
				return tableView.style == .grouped ? CGFloat.leastNormalMagnitude : 0
			}
			return footer.height
		}
		
		public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
			guard indexPath.section < sections.count else { return UITableView.automaticDimension }
			if let indexKeyPath = sections[indexPath.section].sectionKeyPathForRow(indexPath.row), let height = heightAtIndexKeyPath[indexKeyPath] {
				return height
			} else {
				return UITableView.automaticDimension
			}
		}
		
		public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
			guard let header = sections[section].header else { return nil }
			return header.dequeueHeaderFooter(from: tableView)
		}
		
		public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
			guard let footer = sections[section].footer else { return nil }
			return footer.dequeueHeaderFooter(from: tableView)
		}
		
		public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
			let cellConfig = sections[indexPath]
			return cellConfig?.actions.selectionAction != nil
		}
		
		public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
			if tableView.indexPathForSelectedRow == indexPath {
				return nil
			}
			
			guard let cellConfig = sections[indexPath] else {
				return nil
			}
			
			let keyPath = sections.itemPath(from: indexPath)
			
			if let canSelectAction = cellConfig.actions.canSelectAction {
				let canSelectResult: (Bool) -> Void = { selected in
					if #available(iOSApplicationExtension 10.0, *) {
						dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
					}
					if selected {
						tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
						self.tableView(tableView, didSelectRowAt: indexPath)
						NotificationCenter.default.post(name: UITableView.selectionDidChangeNotification, object: tableView)
					} else {
						self.cellStyler.highlightRow(at: keyPath, animated: false, in: tableView)
					}
				}
				DispatchQueue.main.async {
					self.cellStyler.highlightRow(at: keyPath, animated: false, in: tableView)
					canSelectAction(canSelectResult)
				}
				return nil
			} else {
				return indexPath
			}
		}
		
		public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
			guard let cell = tableView.cellForRow(at: indexPath) else { return }
			let cellConfig = sections[indexPath]
			
			let selectionState = cellConfig?.actions.selectionAction?(cell) ?? .deselected
			if selectionState == .deselected {
				DispatchQueue.main.async {
					tableView.deselectRow(at: indexPath, animated: true)
				}
			}
		}
		
		public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
			guard let cell = tableView.cellForRow(at: indexPath) else { return }
			let cellConfig = sections[indexPath]
			
			let selectionState = cellConfig?.actions.deselectionAction?(cell) ?? .deselected
			if selectionState == .selected {
				DispatchQueue.main.async {
					tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
				}
			}
		}
		
		public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
			guard indexPath.section < sections.count else { return }
			
			if let indexKeyPath = sections[indexPath.section].sectionKeyPathForRow(indexPath.row) {
				heightAtIndexKeyPath[indexKeyPath] = cell.bounds.height
			}
			
			if let cellConfig = sections[indexPath] {
				cellConfig.actions.visibilityAction?(cell, true)
				return
			}
		}
		
		public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
			if let cellConfig = sections[indexPath] {
				cellConfig.actions.visibilityAction?(cell, false)
				return
			}
		}
		
		public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
			let tableSection = sections[section]
			tableSection.headerVisibilityAction?(view, true)
		}
		
		public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
			guard section < sections.count else { return }
			let tableSection = sections[section]
			tableSection.headerVisibilityAction?(view, false)
		}
		
		public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
			let cellConfig = sections[indexPath]
			return cellConfig?.actions.canPerformAction != nil
		}
		
		public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
			let cellConfig = sections[indexPath]
			return cellConfig?.actions.canPerformAction?(action) ?? false
		}
		
		public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
			// required
		}
		
		public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
			let cellConfig = sections[indexPath]
			return cellConfig?.actions.rowActions != nil ? .delete : .none
		}
		
		public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
			return false
		}
		
		public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
			return sourceIndexPath.section == proposedDestinationIndexPath.section ? proposedDestinationIndexPath : sourceIndexPath
		}
		
		public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
			let cellConfig = sections[indexPath]
			return cellConfig?.actions.trailingActionConfiguration?.asRowActions(in: tableView) ?? cellConfig?.actions.rowActions
		}
		
		@available(iOSApplicationExtension 11.0, *)
		public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
			let cellConfig = sections[indexPath]
			return cellConfig?.actions.leadingActionConfiguration?.asSwipeActionsConfiguration()
		}

		@available(iOSApplicationExtension 11.0, *)
		public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
			let cellConfig = sections[indexPath]
			return cellConfig?.actions.trailingActionConfiguration?.asSwipeActionsConfiguration()
		}
	}
}
