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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		functionalData.tableView = tableView
		title = "Table View"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAdd))
	}
	
	@objc private func didSelectAdd() {
		items.append(NSDate().description)
	}
	
	private func render() {
		let rows: [CellConfigType] = items.enumerated().map { item in
			return LabelCell(
				key: "id-\(item.offset)",
				actions: CellActions(
					selectionAction: { _ in
						print("\(item.offset) selected")
						return .selected
				},
					deselectionAction: { _ in
						print("\(item.offset) deselected")
						return .deselected
				}),
				state: LabelState(text: .plain(item.element)),
				cellUpdater: LabelState.updateView)
		}
		
		functionalData.renderAndDiff([
			TableSection(key: "section", rows: rows)
        ])
	}
}

