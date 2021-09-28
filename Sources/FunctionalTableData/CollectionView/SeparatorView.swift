//
//  SeparatorView.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-09-30.
//  Copyright © 2021 Shopify. All rights reserved.

import Foundation
import UIKit

public struct SeparatorState: Hashable {
	public let color: UIColor
	public let leadingInset: CGFloat
	public let trailingInset: CGFloat
	public let isHidden: Bool
	
	public init(color: UIColor, leadingInset: CGFloat = 0.0, trailingInset: CGFloat = 0.0, isHidden: Bool = false) {
		self.color = color
		self.leadingInset = leadingInset
		self.trailingInset = trailingInset
		self.isHidden = isHidden
	}
}

extension SeparatorState {
	init(style: Separator.Style?, color: UIColor = .clear) {
		guard let style = style else {
			isHidden = true
			leadingInset = 0.0
			trailingInset = 0.0
			self.color = .clear
			return
		}
		self.color = color
		// the 20.0 here is to support conversion from TableCell, it's the value for leading/trailing layoutMargins
		leadingInset = style.leadingInset.respectingLayoutMargins ? 20.0 + style.leadingInset.value : style.leadingInset.value
		trailingInset = style.trailingInset.respectingLayoutMargins ? 20.0 : style.trailingInset.value
		self.isHidden = false
	}
}

public final class SeparatorView: UIView, ConfigurableView {
	let separator: UIView
	var leadingConstraint: NSLayoutConstraint!
	var trailingConstraint: NSLayoutConstraint!
	
	init() {
		separator = UIView()
		super.init(frame: .zero)
		addSubview(separator)
		separator.translatesAutoresizingMaskIntoConstraints = false
		leadingConstraint = separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0)
		trailingConstraint = separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0)
		NSLayoutConstraint.activate([
			leadingConstraint,
			trailingConstraint,
			separator.topAnchor.constraint(equalTo: topAnchor),
			separator.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func prepareForReuse() {
		separator.backgroundColor = .clear
	}
	
	public func configure(_ state: SeparatorState) {
		self.isHidden = state.isHidden
		separator.backgroundColor = state.color
		leadingConstraint.constant = state.leadingInset
		trailingConstraint.constant = state.trailingInset
	}
}
