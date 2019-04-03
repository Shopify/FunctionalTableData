//
//  ButtonState.swift
//  Shopify
//
//  Created by Raul Riera on 2017-05-02.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

typealias ButtonCell = HostCell<UIButton, ButtonState, LayoutMarginsTableItemLayout>

public struct ButtonState: Equatable {
	public let title: String
	public let isEnabled: Bool
	public let alignment: UIControl.ContentHorizontalAlignment
	public let action: (UIButton) -> Void
	
	public init(title: String, isEnabled: Bool = true, alignment: UIControl.ContentHorizontalAlignment = .center, action: @escaping (UIButton) -> Void) {
		self.title = title
		self.isEnabled = isEnabled
		self.alignment = alignment
		self.action = action
	}
	
	public static func updateView(_ view: UIButton, state: ButtonState?) {
		guard let state = state else {
			view.setTitle(nil, for: .normal)
			view.isEnabled = true
			view.contentHorizontalAlignment = .center
			view.setActions([])
			return
		}
		
		view.setTitle(state.title, for: .normal)
		view.isEnabled = state.isEnabled
		view.contentHorizontalAlignment = state.alignment
		view.setAction(for: .touchUpInside, action: state.action)
	}
	
	public static func ==(lhs: ButtonState, rhs: ButtonState) -> Bool {
		return lhs.title == rhs.title && lhs.isEnabled == rhs.isEnabled && lhs.alignment == rhs.alignment
	}
}
