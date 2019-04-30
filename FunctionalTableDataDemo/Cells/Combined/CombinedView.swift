//
//  CombinedView.swift
//  Shopify
//
//  Created by Geoffrey Foster on 2017-01-18.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

public class CombinedView<View1: UIView, View2: UIView>: UIView {
	public let view1 = View1()
	public let view2 = View2()
	public let stackView: UIStackView
	
	public override init(frame: CGRect) {
		stackView = UIStackView(frame: frame)
		super.init(frame: frame)
		stackView.addArrangedSubview(view1)
		stackView.addArrangedSubview(view2)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
		])
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
