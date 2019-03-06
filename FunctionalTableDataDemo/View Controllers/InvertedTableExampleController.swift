//
//  InvertedTableExampleController.swift
//  FunctionalTableDataDemo
//
//  Created by Rune Madsen on 3/6/19.
//  Copyright © 2019 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

class InvertedTableExampleController: UITableViewController {
	private let functionalData = FunctionalTableData()
	private var items: [String] = [] {
		didSet {
			render()
		}
	}
	
	fileprivate var hasAdjustedInsets: Bool = false
	fileprivate var observedKeyPath: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.transform = CGAffineTransform(rotationAngle: -.pi)
		functionalData.tableView = tableView
		title = "Table View"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAdd))
		
		if #available(iOS 11, *) {
			observedKeyPath = #keyPath(UITableView.safeAreaInsets)
		} else {
			observedKeyPath = #keyPath(UITableView.contentInset)
		}
		tableView.addObserver(self, forKeyPath: observedKeyPath!, options: [.new, .old], context: nil)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == observedKeyPath {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.configureTableViewInsets()
			}
		}
	}
	
	@objc private func didSelectAdd() {
		items.insert(NSDate().description, at: 0)
	}
	
	private func render() {
		let rows: [CellConfigType] = items.enumerated().map { index, item in
			return LabelCell(
				key: "id-\(items.count - index)",
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
		
		functionalData.renderAndDiff([TableSection(key: "section", rows: rows)],
									 animated: true,
									 animations: FunctionalTableData.TableAnimations(sections: FunctionalTableData.TableAnimations.Actions(insert: .none, delete: .none, reload: .none),
																					 rows: FunctionalTableData.TableAnimations.Actions(insert: .top, delete: .none, reload: .none))
		)
	}

	private func configureTableViewInsets() {
		guard hasAdjustedInsets == false else { return }
		
		if #available(iOS 11, *) {
			tableView.contentInsetAdjustmentBehavior = .never
		}
		
		let insets: UIEdgeInsets
		if #available(iOS 11, *) {
			insets = tableView.safeAreaInsets
		} else {
			insets = tableView.contentInset
		}
		
		var tableViewContentInsets = tableView.contentInset
		tableViewContentInsets.bottom = insets.top
		tableViewContentInsets.top = insets.bottom
		tableView.contentInset = tableViewContentInsets

		var scrollIndicatorInsets = tableView.scrollIndicatorInsets
		scrollIndicatorInsets.bottom = insets.top
		scrollIndicatorInsets.top = insets.bottom
		scrollIndicatorInsets.right = tableView.bounds.size.width - 8
		tableView.scrollIndicatorInsets = scrollIndicatorInsets
		
		hasAdjustedInsets = true
	}

}
