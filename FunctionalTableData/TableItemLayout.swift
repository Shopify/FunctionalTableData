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

public typealias EdgeBasedTableItemLayout = Layout<EdgeLayout.Top, EdgeLayout.Leading, EdgeLayout.Bottom, EdgeLayout.Trailing>
public typealias LayoutMarginsTableItemLayout = Layout<MarginsLayout.Top, MarginsLayout.Leading, MarginsLayout.Bottom, MarginsLayout.Trailing>

public struct ExplicitLayoutMarginsTableItemLayout: TableItemLayout {
	public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
		contentView.preservesSuperviewLayoutMargins = false
		
		MarginsLayout.Top.layoutView(view, inContentView: contentView)
		MarginsLayout.Leading.layoutView(view, inContentView: contentView)
		MarginsLayout.Bottom.layoutView(view, inContentView: contentView)
		MarginsLayout.Trailing.layoutView(view, inContentView: contentView)
	}
}

public enum EdgeLayout {
	@available(*, deprecated, message: "Use `Leading` and `EdgeLayout.Trailing` instead.")
	public struct Horizontal: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			Leading.layoutView(view, inContentView: contentView)
			Trailing.layoutView(view, inContentView: contentView)
		}
	}
	
	@available(*, deprecated, message: "Use `EdgeLayout.Top` and `EdgeLayout.Bottom` instead.")
	public struct Vertical: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			Top.layoutView(view, inContentView: contentView)
			Bottom.layoutView(view, inContentView: contentView)
		}
	}
	
	public struct Top: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		}
	}
	
	public struct Leading: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		}
	}
	
	public struct Bottom: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		}
	}
	
	public struct Trailing: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		}
	}
}

public enum MarginsLayout {
	@available(*, deprecated, message: "Use `MarginsLayout.Leading` and `MarginsLayout.Trailing` instead.")
	public struct Horizontal: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			Leading.layoutView(view, inContentView: contentView)
			Trailing.layoutView(view, inContentView: contentView)
		}
	}
	
	@available(*, deprecated, message: "Use `MarginsLayout.Top` and `MarginsLayout.Bottom` instead.")
	public struct Vertical: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			Top.layoutView(view, inContentView: contentView)
			Bottom.layoutView(view, inContentView: contentView)
		}
	}
	
	public struct Top: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			view.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
		}
	}
	
	public struct Leading: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
		}
	}
	
	public struct Bottom: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		}
	}
	
	public struct Trailing: TableItemLayout {
		public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
			contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		}
	}
}

@available(*, deprecated, message: "Use `Layout(Top:Leading:Bottom:Trailing)` instead.")
public struct CombinedLayout<Horizontal: TableItemLayout, Vertical: TableItemLayout>: TableItemLayout {
	public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
		Horizontal.layoutView(view, inContentView: contentView)
		Vertical.layoutView(view, inContentView: contentView)
	}
}

public struct Layout<Top: TableItemLayout, Leading: TableItemLayout, Bottom: TableItemLayout, Trailing: TableItemLayout>: TableItemLayout {
	public static func layoutView(_ view: UIView, inContentView contentView: UIView) {
		Top.layoutView(view, inContentView: contentView)
		Leading.layoutView(view, inContentView: contentView)
		Bottom.layoutView(view, inContentView: contentView)
		Trailing.layoutView(view, inContentView: contentView)
	}
}
