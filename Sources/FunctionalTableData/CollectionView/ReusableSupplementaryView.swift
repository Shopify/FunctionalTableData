//
//  ReusableSupplementaryView.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-09-27.
//  Copyright © 2021 Shopify. All rights reserved.
//

import UIKit

/// A container view for any supplementary view in a CollectionSection
public final class ReusableSupplementaryView<V: UIView & ReusableView>: UICollectionReusableView {
	public let view: V
	
	public override init(frame: CGRect) {
		view = V()
		super.init(frame: frame)
		addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: topAnchor),
			view.leadingAnchor.constraint(equalTo: leadingAnchor),
			view.trailingAnchor.constraint(equalTo: trailingAnchor),
			view.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		view.prepareForReuse()
	}
}
