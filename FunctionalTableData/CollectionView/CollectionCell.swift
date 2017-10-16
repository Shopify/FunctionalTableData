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
	
	public override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		layoutIfNeeded()
		layoutAttributes.size = systemLayoutSizeFitting(UILayoutFittingCompressedSize)
		return layoutAttributes
	}
}
