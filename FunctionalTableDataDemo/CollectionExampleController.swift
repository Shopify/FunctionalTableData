//
//  SecondViewController.swift
//  FunctionalTableDataDemo
//
//  Created by Kevin Barnes on 2018-04-20.
//  Copyright © 2018 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

class CollectionExampleController: UICollectionViewController {
	private let functionalData = FunctionalCollectionData()
	private var items: [String] = [] {
		didSet {
			render()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView?.backgroundColor = .white
		functionalData.collectionView = collectionView
		collectionView?.allowsMultipleSelection = false
		title = "Collection View"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAdd))
	}
	
	@objc private func didSelectAdd() {
		items.append("\(Int(arc4random_uniform(1500)+1))")
	}
	
	private func render() {
		let rows: [CellConfigType] = items.enumerated().map { index, item in
			return LabelCell(
				key: "id-\(index)",
				style: CellStyle(backgroundColor: .lightGray),
				actions: CellActions(
					canSelectAction: { callback in
						callback(true)
				},
					selectionAction: { (view, selected) -> CellActions.SelectionState in
						print("\(item) is \(selected ? "Selected" : "Deselected")")
						return selected ? .selected : .deselected
				}),
				state: LabelState(text: item),
				cellUpdater: LabelState.updateView)
		}
		
		functionalData.renderAndDiff([
			TableSection(key: "section", rows: rows)
			])
	}
}
