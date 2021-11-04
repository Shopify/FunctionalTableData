//
//  CollectionCell.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-10-08.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import UIKit

public class CollectionCell<ViewType: UIView, Layout: TableItemLayout>: UICollectionViewCell {
	public let view: ViewType
	public var prepare: ((_ view: ViewType) -> Void)?
	
	public override init(frame: CGRect) {
		view = ViewType()
		super.init(frame: frame)
		// to get identical layouts to TableCell, we need to add the same layoutMargins that UITableViewCell has
		// from the view debugger, we've determined them (see below), although they are subject to change
		if #available(iOS 11.0, *) {
			contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 11.0, leading: 20.0, bottom: 11.0, trailing: 20.0)
		} else {
			contentView.layoutMargins = UIEdgeInsets(top: 11.0, left: 20.0, bottom: 11.0, right: 20.0)
		}
		contentView.addSubviewsForAutolayout(view)
		Layout.layoutView(view, inContentView: contentView)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		prepare?(view)
		prepare = nil
	}
}

/// A UICollectionReusableView meant to transfer existing TableHeaderFooter views to collection views.
/// Do not use for new supplementary views; prefer ReusableSupplementaryView instead.
public class LegacyTableHeaderFooterView<ViewType: UIView, Layout: TableItemLayout>: UICollectionViewCell {
	public let view: ViewType
	public let topSeparator = Separator(style: Separator.Style.full)
	public let bottomSeparator = Separator(style: Separator.Style.full)
	
	public override init(frame: CGRect) {
		view = ViewType()
		super.init(frame: frame)
		contentView.backgroundColor = UIColor.white
		// to get identical layouts to TableHeaderFooter, we need to add the same layoutMargins that UITableViewCell has
		// From the view debugger, we've determined them (see below), although they are subject to change
		if #available(iOS 11.0, *) {
			contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16.0, leading: 20.0, bottom: 8.0, trailing: 20.0)
		} else {
			contentView.layoutMargins = UIEdgeInsets(top: 16.0, left: 20.0, bottom: 16.0, right: 20.0)
		}
		view.layoutMargins = .zero
		contentView.addSubviewsForAutolayout(view)
		
		addSubviewsForAutolayout(topSeparator, bottomSeparator)
		topSeparator.constrainToTopOfView(self)
		bottomSeparator.constrainToBottomOfView(self)
		
		Layout.layoutView(view, inContentView: contentView)
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

@available(iOS 11.0, *)
private extension NSDirectionalEdgeInsets {
	init(_ edgeInsets: UIEdgeInsets) {
		self.init(top: edgeInsets.top, leading: edgeInsets.left, bottom: edgeInsets.bottom, trailing: edgeInsets.right)
	}
}
