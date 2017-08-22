//
//  AdvancedCellsViewController.swift
//  Examples
//
//  Created by Raul Riera on 2017-08-16.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

class AdvancedCellsViewController: UITableViewController {
	private let tableData = FunctionalTableData()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Advanced Cells"
		
		// Assign the table view that will display the data.
		tableData.tableView = tableView
		// Generate the section, diff and display the changes.
		tableData.renderAndDiff([tableState()])
	}
	
	private func tableState() -> TableSection {
		let cells: [CellConfigType] = [
			// A composite cell by joining two previously created cells together. This one is a bit more complex
			// but shows the power of composition by joining `ImageCell` and `SubtitleCell` into a completely new cell.
			CombinedCell<UIImageView, ImageState, SubtitleView, SubtitleState, LayoutMarginsTableItemLayout>(key: "combinedCell",
			             state: CombinedState(state1: ImageState(image: UIImage(named: "shopifyLogo")!),
			                                  state2: SubtitleState(title: "Subtitle Cell", subtitle: "A cell that can display a title in bolded text and a subtitle with smaller font size.")),
			             cellUpdater: { view, state in
							view.stackView.spacing = state == nil ? 0 : 16
							ImageState.updateView(view.view1, state: state?.state1)
							SubtitleState.updateView(view.view2, state: state?.state2)
			})
		]
		
		// Section style mimicking the default style of UITableView's separator insets.
		return TableSection(key: "section", rows: cells, style: SectionStyle(separators: SectionStyle.Separators(top: nil, bottom: .inset, interitem: .inset)))
	}
}
