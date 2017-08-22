//
//  ButtonCell.swift
//  FunctionalTableData
//
//  Created by Tom Burns on 2017-08-22.
//  Copyright © 2017 Shopify. All rights reserved.
//

import FunctionalTableData

typealias ButtonCell = HostCell<UIButton, ButtonState, EdgeBasedTableItemLayout>

struct ButtonState: Equatable {
	let onPressSelector: Selector
	let onPressTarget: AnyObject
	let buttonText: String
	
	static func updateView(_ view: UIButton, state: ButtonState?) {
		guard let state = state else { return }
		view.setTitle(state.buttonText, for: .normal)
		view.setTitleColor(UIColor.blue, for: .normal)
		view.addTarget(state.onPressTarget, action: state.onPressSelector, for: .touchUpInside)
	}
	
	// MARK: Equatable
	
	static func ==(lhs: ButtonState, rhs: ButtonState) -> Bool {
		return lhs.buttonText == rhs.buttonText
	}
}
