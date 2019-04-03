//
//  FunctionalTableData+UIKeyCommand.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-14.
//  Copyright © 2019 Shopify. All rights reserved.
//

import UIKit

extension FunctionalTableData {
	public final class KeyboardNavigator: NSObject {
		public struct Command: OptionSet {
			public let rawValue: Int
			public init(rawValue: Int) { self.rawValue = rawValue }
			
			public static let upArrow = Command(rawValue: 0 << 0)
			public static let downArrow = Command(rawValue: 0 << 1)
			public static let pageUp = Command(rawValue: 0 << 2)
			public static let pageDown = Command(rawValue: 0 << 3)
			public static let select = Command(rawValue: 0 << 4)
			
			public static let all = Command(rawValue: Int.max)
		}
		
		private var functionalTableData: FunctionalTableData
		public let keyCommands: [UIKeyCommand]
		
		public init(functionalTableData: FunctionalTableData, activeCommands: Command = .all) {
			self.functionalTableData = functionalTableData
			var commands: [UIKeyCommand] = []
			if activeCommands.contains(.upArrow) {
				commands.append(UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(upArrow(_:)), discoverabilityTitle: "Move Up"))
			}
			if activeCommands.contains(.downArrow) {
				commands.append(UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(downArrow(_:)), discoverabilityTitle: "Move Down"))
			}
			if activeCommands.contains(.pageUp) {
				commands.append(UIKeyCommand(input: "UIKeyInputPageUp", modifierFlags: [], action: #selector(pageUp(_:)), discoverabilityTitle: "Page Up"))
			}
			if activeCommands.contains(.pageDown) {
				commands.append(UIKeyCommand(input: "UIKeyInputPageDown", modifierFlags: [], action: #selector(pageDown(_:)), discoverabilityTitle: "Page Down"))
			}
			if activeCommands.contains(.select) {
				commands.append(UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(returnKey(_:)), discoverabilityTitle: "Select"))
			}
			self.keyCommands = commands
			super.init()
		}
		
		@objc private func pageUp(_ sender: UIKeyCommand) {
			guard let tableView = functionalTableData.tableView else { return }
			guard let currentIndexPath = tableView.indexPathsForVisibleRows?.first, let previousIndexPath = tableView.previousIndexPath(before: currentIndexPath) else { return }
			tableView.scrollToRow(at: previousIndexPath, at: .bottom, animated: true)
		}
		
		@objc private func pageDown(_ sender: UIKeyCommand) {
			guard let tableView = functionalTableData.tableView else { return }
			guard let currentIndexPath = tableView.indexPathsForVisibleRows?.last, let nextIndexPath = tableView.nextIndexPath(after: currentIndexPath) else { return }
			tableView.scrollToRow(at: nextIndexPath, at: .top, animated: true)
		}
		
		private var highlightedIndexPath: IndexPath? {
			if let highlightedRow = functionalTableData.highlightedRow {
				return functionalTableData.indexPathFromKeyPath(highlightedRow)
			} else {
				return functionalTableData.tableView?.indexPathForSelectedRow
			}
		}
		
		@objc private func upArrow(_ sender: UIKeyCommand) {
			guard let tableView = functionalTableData.tableView else { return }
			if let previousIndexPath = tableView.previousHighlightable(before: highlightedIndexPath) {
				let keyPath = functionalTableData.keyPathForIndexPath(indexPath: previousIndexPath)
				functionalTableData.scroll(to: keyPath, animated: true, scrollPosition: .top) { [functionalTableData] _ in
					functionalTableData.highlightRow(at: keyPath, animated: false)
				}
			}
		}
		
		@objc private func downArrow(_ sender: UIKeyCommand) {
			guard let tableView = functionalTableData.tableView else { return }
			if let nextIndexPath = tableView.nextHighlightable(after: highlightedIndexPath) {
				let keyPath = functionalTableData.keyPathForIndexPath(indexPath: nextIndexPath)
				functionalTableData.scroll(to: keyPath, animated: true, scrollPosition: .bottom) { [functionalTableData] _ in
					functionalTableData.highlightRow(at: keyPath, animated: false)
				}
			}
		}
		
		@objc private func returnKey(_ sender: UIKeyCommand) {
			guard let highlightedRow = functionalTableData.highlightedRow else { return }
			functionalTableData.select(keyPath: highlightedRow, animated: true, scrollPosition: .none, triggerDelegate: true)
		}
	}
}

private extension UITableView {
	func previousIndexPath(before startIndexPath: IndexPath?, where predicate: ((UITableView, IndexPath) -> Bool)? = nil) -> IndexPath? {
		let startSection = startIndexPath?.section ?? 0
		for sectionIndex in (0...startSection).reversed() {
			var rowRange = (0..<numberOfRows(inSection: sectionIndex)).reversed()
			if let startIndexPath = startIndexPath, sectionIndex == startSection {
				rowRange = (0..<startIndexPath.row).reversed()
			}
			for rowIndex in rowRange {
				let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
				if let predicate = predicate {
					if predicate(self, indexPath) {
						return indexPath
					}
				} else {
					return indexPath
				}
			}
		}
		return nil
	}
	
	func previousHighlightable(before startIndexPath: IndexPath?) -> IndexPath? {
		return previousIndexPath(before: startIndexPath, where: { (tableView, indexPath) -> Bool in
			return tableView.delegate?.tableView?(tableView, shouldHighlightRowAt: indexPath) == true
		})
	}
	
	func nextIndexPath(after startIndexPath: IndexPath?, where predicate: ((UITableView, IndexPath) -> Bool)? = nil) -> IndexPath? {
		guard let startIndexPath = startIndexPath else {
			return IndexPath(row: 0, section: 0)
		}
		let startSection = startIndexPath.section
		for sectionIndex in startSection..<numberOfSections {
			var rowRange = 0..<numberOfRows(inSection: sectionIndex)
			if sectionIndex == startSection {
				rowRange = startIndexPath.row.advanced(by: 1)..<numberOfRows(inSection: sectionIndex)
			}
			for rowIndex in rowRange {
				let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
				if let predicate = predicate {
					if predicate(self, indexPath) {
						return indexPath
					}
				} else {
					return indexPath
				}
			}
		}
		return nil
	}
	
	func nextHighlightable(after startIndexPath: IndexPath?) -> IndexPath? {
		return nextIndexPath(after: startIndexPath, where: { (tableView, indexPath) -> Bool in
			return tableView.delegate?.tableView?(tableView, shouldHighlightRowAt: indexPath) == true
		})
	}
}
