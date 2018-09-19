//
//  CellStyle.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-07-25.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation
import UIKit

/// Defines the presentation information of an item inside a `TableSection`.
///
/// Some properties are only supported by `UITableView`.
public struct CellStyle {
	/// The default selection color to use for styles that don't specify their own.
	public static var defaultSelectionColor: UIColor? = nil
	
	/// The default background color to use for styles that don't specify their own.
	public static var defaultBackgroundColor: UIColor? = .white
	
	@available(*, deprecated, message: "Renamed to defaultSelectionColor.")
	public static var selectionColor: UIColor? {
		get {
			return defaultSelectionColor
		}
		set {
			defaultSelectionColor = newValue
		}
	}
	
	/// The style to apply to the bottom separator in the cell.
	///
	/// Supported by `UITableView` only.
	public var bottomSeparator: Separator.Style?
	/// The style to apply to the top separator in the cell.
	///
	/// Supported by `UITableView` only.
	public var topSeparator: Separator.Style?
	/// The color of separator lines in the cell.
	///
	/// Supported by `UITableView` only.
	public var separatorColor: UIColor?
	/// Whether the cell is highlighted or not.
	///
	/// Supported by `UITableView` only.
	public var highlight: Bool?
	/// The type of standard accessory control used by a cell.
	/// You use these constants when setting the value of the [accessoryType](apple-reference-documentation://hspQPOCGHb) property.
	///
	/// Supported by `UITableView` only.
	public var accessoryType: UITableViewCell.AccessoryType
	/// The view's selection color.
	public var selectionColor: UIColor?
	/// The view's background color.
	public var backgroundColor: UIColor?
	/// The view that is displayed behind the cell’s other content.
	public var backgroundView: UIView?
	/// The tint color to apply to the cell.
	public var tintColor: UIColor?
	/// The default spacing to use when laying out content in the view.
	public var layoutMargins: UIEdgeInsets?
	/// The radius to use when drawing rounded corners in the view.
	public var cornerRadius: CGFloat
	
	public init(topSeparator: Separator.Style? = nil,
	            bottomSeparator: Separator.Style? = nil,
	            separatorColor: UIColor? = nil,
	            highlight: Bool? = nil,
	            accessoryType: UITableViewCell.AccessoryType = .none,
	            selectionColor: UIColor? = CellStyle.defaultSelectionColor,
	            backgroundColor: UIColor? = CellStyle.defaultBackgroundColor,
	            backgroundView: UIView? = nil,
	            tintColor: UIColor? = nil,
	            layoutMargins: UIEdgeInsets? = nil,
	            cornerRadius: CGFloat = 0) {
		self.bottomSeparator = bottomSeparator
		self.topSeparator = topSeparator
		self.separatorColor = separatorColor
		self.highlight = highlight
		self.accessoryType = accessoryType
		self.selectionColor = selectionColor
		self.backgroundColor = backgroundColor
		self.backgroundView = backgroundView
		self.tintColor = tintColor
		self.layoutMargins = layoutMargins
		self.cornerRadius = cornerRadius
	}
	
	func configure(cell: UICollectionViewCell, in collectionView: UICollectionView) {
		cell.backgroundColor = backgroundColor
		cell.backgroundView = backgroundView
		
		if let layoutMargins = layoutMargins {
			cell.contentView.layoutMargins = layoutMargins
		}
		
		cell.tintColor = tintColor
		
		if #available(iOSApplicationExtension 11.0, *) {
			cell.insetsLayoutMarginsFromSafeArea = false
			cell.contentView.insetsLayoutMarginsFromSafeArea = false
		}
		
		if let selectionColor = selectionColor {
			let selectedBackgroundView = UIView()
			selectedBackgroundView.backgroundColor = selectionColor
			cell.selectedBackgroundView = selectedBackgroundView
		} else {
			cell.selectedBackgroundView = nil
		}
		
		cell.layer.cornerRadius = cornerRadius
		cell.layer.masksToBounds = true
	}
	
	func configure(cell: UITableViewCell, in tableView: UITableView) {
		if let separator = bottomSeparator {
			cell.applyBottomSeparator(separator, color: separatorColor)
		} else {
			cell.removeSeparator(Separator.Tag.bottom)
		}
		
		if let separator = topSeparator {
			cell.applyTopSeparator(separator, color: separatorColor)
		} else {
			cell.removeSeparator(Separator.Tag.top)
		}
		
		cell.backgroundColor = backgroundColor
		cell.backgroundView = backgroundView
		
		// SUPER HACK! On iOS 11, setting preserveSuperviewLayoutMargin to true changes the behavior
		// of the layout margins, even when it was already true. Without this fix our layout margins
		// were not being respected and our cells were shorter than on iOS 10
		if cell.contentView.preservesSuperviewLayoutMargins {
			cell.contentView.preservesSuperviewLayoutMargins = true
		}
		
		cell.contentView.layoutMargins = layoutMargins ?? UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		
		cell.tintColor = tintColor
		
		cell.selectionStyle = (highlight ?? false) ? .default : .none
		if let selectionColor = selectionColor {
			let selectedBackgroundView = UIView()
			selectedBackgroundView.backgroundColor = selectionColor
			cell.selectedBackgroundView = selectedBackgroundView
		} else {
			cell.selectedBackgroundView = nil
		}
		
		cell.accessoryType = accessoryType
	}
}

extension CellStyle: Equatable {
	public static func ==(lhs: CellStyle, rhs: CellStyle) -> Bool {
		var equality = lhs.bottomSeparator == rhs.bottomSeparator
		equality = equality && lhs.topSeparator == rhs.topSeparator
		equality = equality && lhs.separatorColor == rhs.separatorColor
		equality = equality && lhs.highlight == rhs.highlight
		equality = equality && lhs.accessoryType == rhs.accessoryType
		equality = equality && lhs.selectionColor == rhs.selectionColor
		equality = equality && lhs.backgroundColor == rhs.backgroundColor
		equality = equality && lhs.backgroundView == rhs.backgroundView
		equality = equality && lhs.tintColor == rhs.tintColor
		equality = equality && lhs.layoutMargins == rhs.layoutMargins
		equality = equality && lhs.cornerRadius == rhs.cornerRadius
		return equality
	}
}
