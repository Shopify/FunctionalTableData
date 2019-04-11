//
//  Separator.swift
//  FunctionalTableData
//
//  Created by Tom Burns on 2016-03-26.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

/// A view used to include separator lines between table cells.
///
/// Use the static `inset` property to globably change the default inset for all table cells. The default background color of a separator is `UIColor.clear`, use [UIAppearance](https://developer.apple.com/documentation/uikit/uiappearance) to modify its value.
///
/// Supported by `UITableView` only.
public class Separator: UIView {
	/// Specifies the default inset of cell separators.
	public static var inset: CGFloat = 0.0
	/// Specifies the default thickness of cell separators.
	private let thickness: CGFloat = 1.0 / UIScreen.main.scale
	
	/// The style for table cells used as separators.
	///
	/// The options are `full`, `inset`, `moreInset`, `custom`
	public enum Style: Equatable {
		case full
		case inset
		case moreInset
		case custom(leadingInset: CGFloat, trailingInset: CGFloat, layoutMarginsRelative: Bool)
		
		public static func ==(lhs: Style, rhs: Style) -> Bool {
			switch (lhs, rhs) {
			case let (.custom(lhsLeadingInset, lhsTrailingInset, lhsLayoutMargins), .custom(rhsLeadingInset, rhsTrailingInset, rhsLayoutMargins)):
				return lhsLeadingInset == rhsLeadingInset && lhsTrailingInset == rhsTrailingInset && lhsLayoutMargins == rhsLayoutMargins
			case (.full, .full):
				return true
			case (.inset, .inset):
				return true
			case (.moreInset, .moreInset):
				return true
			default:
				return false
			}
		}
	}
	
	/// The identifier that can be used to locate a given separator view.
	public enum Tag: Int {
		// numbers are random so subview tags don't conflict
		case top = 2318
		case bottom = 9773
	}

	let style: Style

	public required init(style: Style) {
		self.style = style
		super.init(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: thickness))
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override var intrinsicContentSize: CGSize {
		return CGSize(width: UIView.noIntrinsicMetric, height: thickness)
	}

	public func constrainToTopOfView(_ view: UIView, constant: CGFloat = 0) {
		topAnchor.constraint(equalTo: view.topAnchor, constant: constant).isActive = true
		applyHorizontalConstraints(view)
	}

	public func constrainToBottomOfView(_ view: UIView, constant: CGFloat = 0) {
		bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).isActive = true
		applyHorizontalConstraints(view)
	}

	private func applyHorizontalConstraints(_ view: UIView) {
		switch style {
		case .full, .inset, .moreInset:
			trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		case .custom(_, let trailingInset, let layoutMarginsRelative):
			if layoutMarginsRelative {
				trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -trailingInset).isActive = true
			} else {
				trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingInset).isActive = true
			}
		}
		
		switch style {
		case .full:
			leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		case .moreInset:
			leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 3 * Separator.inset).isActive = true
		case .inset:
			leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
		case .custom(let leadingInset, _, let layoutMarginsRelative):
			if layoutMarginsRelative {
				leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: leadingInset).isActive = true
			} else {
				leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingInset).isActive = true
			}
		}
	}
}

public extension UIView {
	/// Applies an instance of a `Separator` view to the top of the current view.
	///
	/// - Parameters:
	///   - style: the separator inset style.
	///   - color: the separator color.
	func applyTopSeparator(_ style: Separator.Style, color: UIColor? = nil) {
		removeSeparator(Separator.Tag.top)
		let separator = Separator(style: style)
		separator.tag = Separator.Tag.top.rawValue
		if let color = color {
			separator.backgroundColor = color
		}
		addSubviewsForAutolayout(separator)
		separator.constrainToTopOfView(self)
	}
	
	/// Applies an instance of a `Separator` view to the bottom of the current view.
	///
	/// - Parameters:
	///   - style: the separator inset style.
	///   - color: the separator color.
	func applyBottomSeparator(_ style: Separator.Style, color: UIColor? = nil) {
		removeSeparator(Separator.Tag.bottom)
		let separator = Separator(style: style)
		separator.tag = Separator.Tag.bottom.rawValue
		if let color = color {
			separator.backgroundColor = color
		}
		addSubviewsForAutolayout(separator)
		separator.constrainToBottomOfView(self)
	}
	
	/// Removes any instance of a `Separator` view from the current view.
	///
	/// - Parameter withTag: the separator to remove.
	func removeSeparator(_ withTag: Separator.Tag) {
		guard let separator = viewWithTag(withTag.rawValue) as? Separator else { return }
		separator.removeFromSuperview()
	}
}
