//
//  TodoListViewController.swift
//  FunctionalTableData
//
//  Created by Tom Burns on 2017-08-22.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation

//
//  BasicCellsViewController.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-08-02.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

class TodoListViewController: UITableViewController {
	private let tableData = FunctionalTableData()
	private var todoList = [
		"Install FTD",
		"Star FTD on Github",
		"Tell my friends about FTD",
		"Apply to work at Shopify",
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "TODO List"
		
		// Assign the table view that will display the data.
		tableData.tableView = tableView
		
		// Generate the section, diff and display the changes.
		tableData.renderAndDiff(tableState())
	}
	
	private func tableState() -> [TableSection] {
		let listSection = TableSection(
			key: "todoList",
			rows: todoList.enumerated().map { (index, todoItem) in
				LabelCell(key: "todo\(index)",
				          state: todoItem) { $0.text = $1 }
			},
			
			style: SectionStyle(separators: SectionStyle.Separators(top: nil, bottom: .inset, interitem: .inset)))
		
		let inputSection = TableSection(
			key: "inputSection",
			rows: [
				ButtonCell(
					key: "inputButton",
					state: ButtonState(
						onPressSelector: #selector(addTodoItem),
						onPressTarget: self,
						buttonText: "Add Todo Item"
					),
					cellUpdater: ButtonState.updateView
				)
			])

		// Section style mimicking the default style of UITableView's separator insets.
		return [listSection, inputSection]
	}
	
	func addTodoItem() {
		todoList.append("New TODO Item")
		tableData.renderAndDiff(tableState())
	}
}
