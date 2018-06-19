//
//  UIView+Extensions.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-07-31.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit

extension UIView {
	func typedSuperview<T: UIView>() -> T? {
		var parent = superview
		
		while parent != nil {
			if let view = parent as? T {
				return view
			} else {
				parent = parent?.superview
			}
		}
		
		return nil
	}
}
