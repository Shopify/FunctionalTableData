//
//  BasicCellsViewController.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-08-02.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

class BasicCellsViewController: UITableViewController {
	private let tableData = FunctionalTableData()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Basic Cells"
		
		// Assign the table view that will display the data.
		tableData.tableView = tableView
		// Generate the section, diff and display the changes.
		tableData.renderAndDiff([section()])
	}
	
	private func section() -> TableSection {
		let cells: [CellConfigType] = [
			// Since this cell is more complex than `LabelCell`, pass the updateView method into cellUpdater instead of making any updates inline.
			SubtitleCell(key: "subtitleCell",
			             state: SubtitleState(title: "Functional Table Data", subtitle: "Functional Table Data takes a complete, idempotent description of your table state, compares it with the previous render call to compute which cells have changed, and updates the UITableView."),
			             cellUpdater: SubtitleState.updateView)
		]
		
		// Section style mimicking the default style of UITableView's separator insets.
		return TableSection(key: "section", rows: cells, style: SectionStyle(separators: SectionStyle.Separators(top: nil, bottom: .inset, interitem: .inset)))
	}
}
