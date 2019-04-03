//
//  SpacerCell.swift
//  Shopify
//
//  Created by Raul Riera on 2017-12-18.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import UIKit
import FunctionalTableData

public class SpacerView: UIView {
	public var height: CGFloat = 12 {
		didSet {
			invalidateIntrinsicContentSize()
		}
	}
	
	public override var intrinsicContentSize: CGSize {
		return CGSize(width: UIView.noIntrinsicMetric, height: height)
	}
}
