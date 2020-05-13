//
//  Accessibility.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2020-04-28.
//  Copyright © 2020 Shopify. All rights reserved.
//

import UIKit

public struct Accessibility: Equatable {
	public var identifier: String?
	public var userInputLabels: [String]?
	
	public init(identifier: String? = nil, userInputLabels: [String]? = nil) {
		self.identifier = identifier
		self.userInputLabels = userInputLabels
	}
	
	internal func with(defaultIdentifier: String) -> Accessibility {
		guard identifier == nil else { return self }
		var copy = self
		copy.identifier = defaultIdentifier
		return copy
	}
}

extension Accessibility {
	func apply(to cell: UITableViewCell) {
		cell.accessibilityIdentifier = identifier
		if #available(iOS 13.0, *) {
			cell.accessibilityUserInputLabels = userInputLabels
		}
	}
	
	func apply(to cell: UICollectionViewCell) {
		cell.accessibilityIdentifier = identifier
		if #available(iOS 13.0, *) {
			cell.accessibilityUserInputLabels = userInputLabels
		}
	}
}
