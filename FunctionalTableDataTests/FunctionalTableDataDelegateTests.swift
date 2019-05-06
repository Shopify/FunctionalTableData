//
//  FunctionalTableDataDelegateTests.swift
//  FunctionalTableDataTests
//
//  Created by Geoffrey Foster on 2019-04-01.
//  Copyright © 2019 Shopify. All rights reserved.
//

import XCTest
@testable import FunctionalTableData

class FunctionalTableDataDelegateTests: XCTestCase {
	let tableView = UITableView(frame: .zero, style: .plain)
	
	func testLeadingTrailingRowActions() {
		let actions = CellActions(
			leadingActionConfiguration: CellActions.SwipeActionsConfiguration(
				actions: [
					CellActions.SwipeActionsConfiguration.ContextualAction(title: "Hi", style: .normal, handler: { (_, _) in })
				]
			),
			trailingActionConfiguration: CellActions.SwipeActionsConfiguration(
				actions: [
					CellActions.SwipeActionsConfiguration.ContextualAction(title: "Bye", style: .normal, handler: { (_, _) in })
				]
			)
		)
		let cell = HostCell<UIView, String, LayoutMarginsTableItemLayout>(key: "actions", actions: actions, state: "Actions") { (_, _) in }
		let data = TableData()
		data.sections = [TableSection(key: "Section", rows: [cell])]
		let delegate = FunctionalTableData.Delegate(
			cellStyler: FunctionalTableData.CellStyler(
				data: data
			)
		)
		let indexPath = IndexPath(row: 0, section: 0)
		
		let rowActions = delegate.tableView(tableView, editActionsForRowAt: indexPath)
		XCTAssertNotNil(rowActions)
		XCTAssertEqual(rowActions?.first?.title, "Bye")
		
		let leadingSwipeActionsConfiguration = delegate.tableView(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath)
		XCTAssertNotNil(leadingSwipeActionsConfiguration)
		XCTAssertEqual(leadingSwipeActionsConfiguration?.actions.first?.title, "Hi")
		
		let trailingActionConfiguration = delegate.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
		XCTAssertNotNil(trailingActionConfiguration)
		XCTAssertEqual(trailingActionConfiguration?.actions.first?.title, "Bye")
	}
}
