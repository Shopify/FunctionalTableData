//
//  LabelViewState.swift
//  Shopify
//
//  Created by Geoffrey Foster on 2016-10-30.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

public typealias LabelCell = HostCell<UILabel, LabelState, LayoutMarginsTableItemLayout>

public struct LabelState: Equatable {
	let text: ControlText
	let font: UIFont?
	let textColor: UIColor?
	let truncationStyle: TruncationStyle
	let textAlignment: NSTextAlignment
	
	public init(text: ControlText, font: UIFont? = nil, textColor: UIColor? = nil, truncationStyle: TruncationStyle = .truncate, textAlignment: NSTextAlignment = .natural) {
		self.text = text
		self.font = font
		self.textColor = textColor
		self.truncationStyle = truncationStyle
		self.textAlignment = textAlignment
	}
	
	public static func updateView(_ view: UILabel, state: LabelState?) {
		guard let state = state else {
			view.setControlText(nil)
			return
		}
		
		view.font = state.font
		view.textColor = state.textColor
		view.apply(truncationStyle: state.truncationStyle)
		view.setControlText(state.text)
		view.textAlignment = state.textAlignment
	}
}
