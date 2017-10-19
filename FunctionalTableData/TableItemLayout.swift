//
//  TableItemLayout.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-10-08.
//  Copyright © 2017 Raul Riera. All rights reserved.
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
