//
//  FunctionalTableData+UITableViewDataSource.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-08.
//  Copyright © 2019 Shopify. All rights reserved.
//

import Foundation

extension FunctionalTableData {
	class DataSource: NSObject, UITableViewDataSource {
		var sections: [TableSection] = []
		
		public func numberOfSections(in tableView: UITableView) -> Int {
			return sections.count
		}
		
		public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return sections[section].rows.count
		}
		
		public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let sectionData = sections[indexPath.section]
			let row = indexPath.row
			let cellConfig = sectionData[row]
			let cell = cellConfig.dequeueCell(from: tableView, at: indexPath)
			cell.accessibilityIdentifier = ItemPath(sectionKey: sectionData.key, itemKey: cellConfig.key).description
			
			cellConfig.update(cell: cell, in: tableView)
			let style = sectionData.mergedStyle(for: row)
			style.configure(cell: cell, in: tableView)
			
			return cell
		}
		
		public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
			// Should only ever be moving within section
			assert(sourceIndexPath.section == destinationIndexPath.section)
			
			// Update internal state to match move
			let cell = sections[sourceIndexPath.section].rows.remove(at: sourceIndexPath.row)
			sections[destinationIndexPath.section].rows.insert(cell, at: destinationIndexPath.row)
			
			sections[sourceIndexPath.section].didMoveRow?(sourceIndexPath.row, destinationIndexPath.row)
		}
		
		public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
			return sections[indexPath]?.actions.canBeMoved ?? false
		}
		
		public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
			guard let cellConfig = sections[indexPath] else { return false }
			return cellConfig.actions.hasEditActions || self.tableView(tableView, canMoveRowAt: indexPath)
		}
	}
}
