//
//  TableCell.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-09-10.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

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
		
		addSubviewsForAutolayout(topSeparator, bottomSeparator)
		topSeparator.constrainToTopOfView(self)
		bottomSeparator.constrainToBottomOfView(self)
		
		Layout.layoutView(view, inContentView: contentView)
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
