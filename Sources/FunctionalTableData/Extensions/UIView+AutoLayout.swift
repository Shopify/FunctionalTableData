//
//  UIView+Autolayout.swift
//  FunctionalTableData
//
//  Created by Chris Sauve on 2015-11-30.
//  Copyright © 2015 Shopify. All rights reserved.
//

import UIKit

extension UIView {
	func addSubviewsForAutolayout(_ views: UIView...) {
		views.forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
	}
}
