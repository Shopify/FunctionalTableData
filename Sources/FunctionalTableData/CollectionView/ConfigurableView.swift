//
//  ConfigurableView.swift
//	FunctionalTableData
//
//  Created by Jason Kemp on 2021-10-19.
//	Copyright © 2021 Shopify. All rights reserved.

import UIKit

public protocol ReusableView {
	func prepareForReuse()
}

public protocol ConfigurableView: ReusableView {
	associatedtype State
	
	func configure(_ state: State)
}

/// Represents a view that can be highlighted.
/// Intended for custom highlighting. Set CellStyle.highlight to false and implement this protocol to customize how the
/// cell is highlighted.
public protocol HighlightableView: UIView {
	var isHighlighted: Bool { get set }
}

public final class ConfigurableCollectionCell<View: UIView & ConfigurableView, State>: UICollectionViewCell where View.State == State {
	let view: View
	
	override public var isHighlighted: Bool {
		get { super.isHighlighted }
		set {
			super.isHighlighted = newValue
			if let view = view as? HighlightableView {
				view.isHighlighted = newValue
			}
		}
	}
	
	public override init(frame: CGRect) {
		view = View()
		super.init(frame: frame)
		contentView.addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: contentView.topAnchor),
			view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		view.prepareForReuse()
	}
	
	public func configure(_ state: State) {
		view.configure(state)
	}
}
