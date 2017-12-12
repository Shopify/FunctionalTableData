//
//  CellStyle.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-07-25.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation
import UIKit

public struct CellStyle {
	public static var selectionColor: UIColor? = nil // TODO: make this not a static like this
	public var bottomSeparator: Separator.Style?
	public var topSeparator: Separator.Style?
	public var separatorColor: UIColor?
	public var highlight: Bool?
	public var accessoryType: UITableViewCellAccessoryType = .none
	public var selectionColor: UIColor? = CellStyle.selectionColor
	public var backgroundColor: UIColor?
	public var backgroundView: UIView?
	public var tintColor: UIColor?
	public var layoutMargins: UIEdgeInsets?
	public var cornerRadius: CGFloat
	
	public init(topSeparator: Separator.Style? = nil,
	            bottomSeparator: Separator.Style? = nil,
	            separatorColor: UIColor? = nil,
	            highlight: Bool? = nil,
	            accessoryType: UITableViewCellAccessoryType = .none,
	            selectionColor: UIColor? = CellStyle.selectionColor,
	            backgroundColor: UIColor? = nil,
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
		if let backgroundView = backgroundView {
			cell.backgroundView = backgroundView
		} else {
			cell.backgroundColor = backgroundColor ?? UIColor.white
			let backgroundView = UIView()
			backgroundView.backgroundColor = cell.backgroundColor
			cell.backgroundView = backgroundView
		}
		
		if let layoutMargins = layoutMargins {
			cell.contentView.layoutMargins = layoutMargins
		}
		
		cell.tintColor = tintColor
		
		if #available(iOS 11.0, *) {
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
		
		if let backgroundView = backgroundView {
			cell.backgroundView = backgroundView
		} else {
			cell.backgroundColor = backgroundColor ?? UIColor.white
			let backgroundView = UIView()
			backgroundView.backgroundColor = cell.backgroundColor
			cell.backgroundView = backgroundView
		}
		
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
		return equality
	}
}
