//
//  ExamplesViewController.swift
//  Examples
//
//  Created by Raul Riera on 2017-08-02.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

class ExamplesViewController: UITableViewController {
	private let tableData = FunctionalTableData()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Examples"
		
		// Assign the table view that will display the data
		tableData.tableView = tableView
		// Generate the section, diff and display the changes
		tableData.renderAndDiff([section()])
	}
	
	private func section() -> TableSection {
		let cells: [CellConfigType] = [
			LabelCell(key: "basic",
			          style: CellStyle(accessoryType: .disclosureIndicator),
			          actions: CellActions(selectionAction: { [weak self] _ in
						  self?.openBasicCells()
						  return .deselected
					  }),
			          state: "Basic cells") { view, state in
				view.text = state
			},
			LabelCell(key: "advanced",
			          style: CellStyle(accessoryType: .disclosureIndicator),
			          actions: CellActions(selectionAction: { [weak self] _ in
						self?.openAdvancedCells()
						return .deselected
					}),
			          state: "Advanced cells") { view, state in
						view.text = state
			},
			LabelCell(key: "todo",
			          style: CellStyle(accessoryType: .disclosureIndicator),
			          actions: CellActions(selectionAction: { [weak self] _ in
									self?.openTodoList()
									return .deselected
								}),
			          state: "TODO List") { view, state in
									view.text = state
			}
		]
		
		// Section style mimicking the default style of UITableView's separator insets.
		return TableSection(key: "section", rows: cells, style: SectionStyle(separators: SectionStyle.Separators(top: nil, bottom: .inset, interitem: .inset)))
	}
	
	private func openBasicCells() {
		navigationController?.pushViewController(BasicCellsViewController(), animated: true)
	}
	
	private func openAdvancedCells() {
		navigationController?.pushViewController(AdvancedCellsViewController(), animated: true)
	}
	
	private func openTodoList() {
		navigationController?.pushViewController(TodoListViewController(), animated: true)
	}
}
