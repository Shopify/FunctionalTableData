//
//  TableCell.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-09-10.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

public protocol TableItemLayout {
	static func layoutView(_ view: UIView, inContentView contentView: UIView)
}

// TableItemLayout

public typealias EdgeBasedTableItemLayout = CombinedLayout<EdgeLayout.Horizontal, EdgeLayout.Vertical>
public typealias LayoutMarginsTableItemLayout = CombinedLayout<MarginsLayout.Horizontal, MarginsLayout.Vertical>

public struct ExplicitLayoutMarginsTableItemLayout: TableItemLayout {
	public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
		contentView.preservesSuperviewLayoutMargins = false
		view.constrainToFillView(contentView, respectingLayoutMargins: true)
	}
}

public enum EdgeLayout {
	public struct Horizontal: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			view.constrainToFillViewHorizontally(contentView)
		}
	}
	public struct Vertical: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			view.constrainToFillViewVertically(contentView)
		}
	}
}
public enum MarginsLayout {
	public struct Horizontal: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			view.constrainToFillViewHorizontally(contentView, respectingLayoutMargins: true)
		}
	}
	public struct Vertical: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			view.constrainToFillViewVertically(contentView, respectingLayoutMargins: true)
		}
	}
}

public struct CombinedLayout<Horizontal: TableItemLayout, Vertical: TableItemLayout>: TableItemLayout {
	public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
		Horizontal.layoutView(view, inContentView: contentView)
		Vertical.layoutView(view, inContentView: contentView)
	}
}

// Table item classes

public class TableCell<ViewType: UIView, Layout: TableItemLayout>: UITableViewCell {
	public let view: ViewType
	public var prepare: ((_ view: ViewType) -> Void)?
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		view = ViewType()
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		contentView.addSubviewsForAutolayout(view)
		Layout.layoutView(view, inContentView: contentView)
	}
	
	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		prepare?(view)
		prepare = nil
	}
}

public class TableHeaderFooter<ViewType: UIView, Layout: TableItemLayout>: UITableViewHeaderFooterView {
	public let view: ViewType
	public let topSeparator = Separator(style: Separator.Style.full)
	public let bottomSeparator = Separator(style: Separator.Style.full)
	
	public override init(reuseIdentifier: String?) {
		view = ViewType()
		super.init(reuseIdentifier: reuseIdentifier)
		
		contentView.backgroundColor = UIColor.white
		contentView.layoutMargins = view.layoutMargins
		view.layoutMargins = .zero
		contentView.addSubviewsForAutolayout(view)
		
		contentView.addSubviewsForAutolayout(topSeparator, bottomSeparator)
		topSeparator.constrainToTopOfView(contentView)
		bottomSeparator.constrainToBottomOfView(contentView)
		
		Layout.layoutView(view, inContentView: contentView)
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
