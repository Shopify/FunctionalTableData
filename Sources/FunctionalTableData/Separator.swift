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
	/// The style for table cells used as separators.
	public struct Style: Equatable, Hashable {
		/// The inset used in the separators.
		public struct Inset: Equatable, Hashable {
			/// Specifies the amount of spacing to apply to the separator.
			public let value: CGFloat
			/// Specifies if the inset is relative to the layout margins.
			public let respectingLayoutMargins: Bool

			public static let none: Inset = Inset(value: 0, respectingLayoutMargins: false)
			
			public init(value: CGFloat, respectingLayoutMargins: Bool) {
				self.value = value
				self.respectingLayoutMargins = respectingLayoutMargins
			}
		}
		
		/// Specifies the leading inset of the separators.
		public let leadingInset: Inset
		/// Specifies the trailing inset of the separators.
		public let trailingInset: Inset
		/// Specifies the thickness of cell separators.
		public let thickness: CGFloat
		/// A separator going from the leading edge to the trailing edge of the screen.
		static public let full: Style = Style(leadingInset: .none, trailingInset: .none)
		/// A separator going from the leading margin to the trailing edge of the screen.
		static public let inset: Style = Style(leadingInset: .init(value: 0, respectingLayoutMargins: true), trailingInset: .none)
		
		/// Initializes and returns a newly separator style.
		///
		/// - Parameters:
		///   - leadingInset: The spacing to use from the leading edge.
		///   - trailingInset: The spacing to use from the trailing edge.
		///   - thickness: The thickness of the separator.
		public init(leadingInset: Inset, trailingInset: Inset, thickness: CGFloat = 1.0 / UIScreen.main.scale) {
			self.leadingInset = leadingInset
			self.trailingInset = trailingInset
			self.thickness = thickness
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
		super.init(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: style.thickness))
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override var intrinsicContentSize: CGSize {
		return CGSize(width: UIView.noIntrinsicMetric, height: style.thickness)
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
		if style.leadingInset.respectingLayoutMargins {
			leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: style.leadingInset.value).isActive = true
		} else {
			leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: style.leadingInset.value).isActive = true
		}
		
		if style.trailingInset.respectingLayoutMargins {
			trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -style.trailingInset.value).isActive = true
		} else {
			trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -style.trailingInset.value).isActive = true
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
