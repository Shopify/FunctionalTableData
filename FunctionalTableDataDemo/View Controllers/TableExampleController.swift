//
//  FirstViewController.swift
//  FunctionalTableDataDemo
//
//  Created by Kevin Barnes on 2018-04-20.
//  Copyright © 2018 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

class TableExampleController: UITableViewController {
	private let functionalData = FunctionalTableData()
	private var items: [String] = [] {
		didSet {
			render()
		}
	}
	private lazy var keyboardNavigator = FunctionalTableData.KeyboardNavigator(functionalTableData: functionalData)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		functionalData.tableView = tableView
		title = "Table View"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAdd))
	}
	
	@objc private func didSelectAdd() {
		items.append(NSDate().description)
	}
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	override var keyCommands: [UIKeyCommand]? {
		return keyboardNavigator.keyCommands
	}
	
	open override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
		//return target(forAction: action, withSender: sender, keyCommandProviders: keyCommandProviders)
		if let keyCommand = sender as? UIKeyCommand, keyboardNavigator.keyCommands.contains(keyCommand) {
			return keyboardNavigator
		} else {
			return super.target(forAction: action, withSender: sender)
		}
	}
	
	private func render() {
		let rows: [CellConfigType] = items.enumerated().map { index, item in
			return LabelCell(
				key: "id-\(index)",
				actions: CellActions(
					selectionAction: { _ in
						print("\(item) selected")
						return .selected
				},
					deselectionAction: { _ in
						print("\(item) deselected")
						return .deselected
				}),
				state: LabelState(text: item),
				cellUpdater: LabelState.updateView)
		}
		
		functionalData.renderAndDiff([
			TableSection(key: "section", rows: rows)
		])
	}
}

