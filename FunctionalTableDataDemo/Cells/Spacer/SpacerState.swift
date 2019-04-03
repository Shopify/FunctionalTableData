//
//  SpacerCell.swift
//  Shopify
//
//  Created by Raul Riera on 2017-12-18.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import UIKit
import FunctionalTableData

public typealias SpacerCell = HostCell<SpacerView, SpacerState<SpacerView>, EdgeBasedTableItemLayout>

public struct SpacerState<View: SpacerView>: Equatable {
	public let height: CGFloat
	
	public init(height: CGFloat = 12) {
		self.height = height
	}
	
	public static func updateView(_ view: View, state: SpacerState?) {
		view.backgroundColor = UIColor.clear
		view.height = state?.height ?? 12
	}
	
	public static func ==(lhs: SpacerState, rhs: SpacerState) -> Bool {
		return lhs.height == rhs.height
	}
}
