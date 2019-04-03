//
//  SubtitleCell.swift
//  Shopify
//
//  Created by Raul Riera on 2017-09-21.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

public class SubtitleView: UIView {
	let stackView = UIStackView()
	let titleLabel = UILabel()
	let subtitleLabel = UILabel()
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) is not implemented")
	}
	
	fileprivate func setup() {
		stackView.axis = .vertical
		stackView.alignment = .leading
		stackView.spacing = 4
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(subtitleLabel)
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
		])
		
		titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
	}
}
