//
//  Separator.swift
//  FunctionalTableData
//
//  Created by Tom Burns on 2016-03-26.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

public class Separator: UIView {
	public static var inset: CGFloat = 0.0
	private let thickness: CGFloat = 1.0 / UIScreen.main.scale
	
	public enum Style {
		case full
		case inset
		case moreInset
		
		public var insetDistance: CGFloat {
			switch self {
			case .inset:
				return Separator.inset
			case .full:
				return 0
			case .moreInset:
				return 3 * Separator.inset
			}
		}
	}
	
	public enum Tag: Int {
		// numbers are random so subview tags dont conflict
		case top = 2318
		case bottom = 9773
		
		var intValue: Int {
			return self.rawValue
		}
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
		return CGSize(width: UIViewNoIntrinsicMetric, height: thickness)
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
		trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		switch style {
		case .full, .moreInset:
			leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: style.insetDistance).isActive = true
		case .inset:
			leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
		}
	}
}

public extension UIView {
	public func applyTopSeparator(_ style: Separator.Style, color: UIColor? = nil) {
		removeSeparator(Separator.Tag.top)
		let separator = Separator(style: style)
		separator.tag = Separator.Tag.top.rawValue
		if let color = color {
			separator.backgroundColor = color
		}
		addSubviewsForAutolayout(separator)
		separator.constrainToTopOfView(self)
	}
	
	public func applyBottomSeparator(_ style: Separator.Style, color: UIColor? = nil) {
		removeSeparator(Separator.Tag.bottom)
		let separator = Separator(style: style)
		separator.tag = Separator.Tag.bottom.rawValue
		if let color = color {
			separator.backgroundColor = color
		}
		addSubviewsForAutolayout(separator)
		separator.constrainToBottomOfView(self)
	}
	
	public func removeSeparator(_ withTag: Separator.Tag) {
		guard let separator = viewWithTag(withTag.rawValue) as? Separator else { return }
		separator.removeFromSuperview()
	}
}
