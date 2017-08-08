//
//  SpacerCell.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-08-03.
//  Copyright © 2017 Shopify. All rights reserved.
//

import FunctionalTableData

typealias SpacerCell = HostCell<SpacerView, SpacerState, EdgeBasedTableItemLayout>

class SpacerView: UIView {
	var height: CGFloat = 0 {
		didSet {
			invalidateIntrinsicContentSize()
		}
	}
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIViewNoIntrinsicMetric, height: height)
	}
}

struct SpacerState: Equatable {
	let height: CGFloat
	
	init(height: CGFloat = 8) {
		self.height = height
	}
	
	static func updateView(_ view: SpacerView, state: SpacerState?) {
		guard let state = state else { return }
		view.height = state.height
	}
	
	// MARK: Equatable
	
	static func ==(lhs: SpacerState, rhs: SpacerState) -> Bool {
		return lhs.height == rhs.height
	}
}
