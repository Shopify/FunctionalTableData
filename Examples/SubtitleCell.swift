//
//  SubtitleCell.swift
//  Examples
//
//  Created by Raul Riera on 2017-08-02.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

// Cell mimicking the style of the default iOS cell "Subtitle".
typealias SubtitleCell = HostCell<SubtitleView, SubtitleState, LayoutMarginsTableItemLayout>

// View counter part of the SubtitleCell
class SubtitleView: UIView {
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
		stackView.translatesAutoresizingMaskIntoConstraints = false

		addSubview(stackView)
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(subtitleLabel)
		
		NSLayoutConstraint.activate([
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
		subtitleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
		
		// For simplicity, hardcode the font styles in the view
		titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
		subtitleLabel.font = UIFont.systemFont(ofSize: 14)
		subtitleLabel.numberOfLines = 0
	}
}

// State counterpart of the SubtitleCell
struct SubtitleState: Equatable {
	let title: String
	let subtitle: String
	
	public static func updateView(_ view: SubtitleView, state: SubtitleState?) {
		view.titleLabel.text = state?.title
		view.subtitleLabel.text = state?.subtitle
	}
	
	// MARK: Equatable
	
	static func ==(lhs: SubtitleState, rhs: SubtitleState) -> Bool {
		return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
	}
}
