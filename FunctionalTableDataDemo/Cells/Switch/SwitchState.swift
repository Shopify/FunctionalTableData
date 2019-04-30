//
//  SwitchState.swift
//  Shopify
//
//  Created by Raul Riera on 02/02/2017.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

public typealias SwitchCell = HostCell<CombinedView<UILabel, UISwitch>, CombinedState<LabelState, SwitchState>, LayoutMarginsTableItemLayout>

public struct SwitchState: Equatable {
	let isEnabled: Bool
	let isOn: Bool
	let onValueChanged: (Bool) -> Void
	
	public init(isEnabled: Bool = true, isOn: Bool, onValueChanged: @escaping (Bool) -> Void) {
		self.isEnabled = isEnabled
		self.isOn = isOn
		self.onValueChanged = onValueChanged
	}
	
	public static func updateView(_ view: UISwitch, state: SwitchState?) {		
		view.isOn = state?.isOn ?? false
		view.isEnabled = state?.isEnabled ?? false
		view.setAction(for: .valueChanged) { switchView in
			state?.onValueChanged(switchView.isOn)
		}
		// UISwitch won't layout properly if we don't specify a compression resistance
		// otherwise it will be moved away by a sibling view
		view.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		// Allocates the bare minimum horizontal space to the switch in a stackview
		view.setContentHuggingPriority(.required, for: .horizontal)
		
		// Prevents stackViews from shrinkwrapping so eagerly to the switch that it cuts off multiline labels
		view.setContentHuggingPriority(.defaultLow, for: .vertical)
	}
	
	public static func ==(lhs: SwitchState, rhs: SwitchState) -> Bool {
		return lhs.isEnabled == rhs.isEnabled && lhs.isOn == rhs.isOn
	}
}
