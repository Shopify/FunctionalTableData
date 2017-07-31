//
//  UIView+Autolayout.swift
//  FunctionalTableData
//
//  Created by Chris Sauve on 2015-11-30.
//  Copyright © 2015 Shopify. All rights reserved.
//

import UIKit

extension UIView {
	func constraintsToFillView(_ otherView: UIView, respectingLayoutMargins: Bool = false) -> [NSLayoutConstraint] {
		return constraintsToFillViewHorizontally(otherView, respectingLayoutMargins: respectingLayoutMargins) + constraintsToFillViewVertically(otherView, respectingLayoutMargins: respectingLayoutMargins)
	}
	
	func constraintsToFillView(_ otherView: UIView, insetBy margins: UIEdgeInsets, respectingLayoutMargins: Bool = false) -> [NSLayoutConstraint] {
		
		if respectingLayoutMargins {
			let layoutMarginsGuide = otherView.layoutMarginsGuide
			
			return [
				topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: margins.top),
				bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -margins.bottom),
				leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: margins.left),
				trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -margins.right)
			]
		} else {
			return [
				topAnchor.constraint(equalTo: otherView.topAnchor, constant: margins.top),
				bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: -margins.bottom),
				leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: margins.left),
				trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: -margins.right)
			]
		}
	}
	
	func constraintsToFillViewVertically(_ otherView: UIView, respectingLayoutMargins: Bool = false) -> [NSLayoutConstraint] {
		if respectingLayoutMargins {
			let layoutMarginsGuide = otherView.layoutMarginsGuide
			
			return [
				topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
				bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
			]
		} else {
			return [
				topAnchor.constraint(equalTo: otherView.topAnchor),
				bottomAnchor.constraint(equalTo: otherView.bottomAnchor)
			]
		}
	}
	
	func constraintsToFillViewHorizontally(_ otherView: UIView, respectingLayoutMargins: Bool = false) -> [NSLayoutConstraint] {
		if respectingLayoutMargins {
			let layoutMarginsGuide = otherView.layoutMarginsGuide
			
			return [
				leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
				trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
			]
		} else {
			return [
				leadingAnchor.constraint(equalTo: otherView.leadingAnchor),
				trailingAnchor.constraint(equalTo: otherView.trailingAnchor)
			]
		}
	}
	
	func constraintsToBeCenteredInView(_ otherView: UIView) -> [NSLayoutConstraint] {
		return [
			centerXAnchor.constraint(equalTo: otherView.centerXAnchor),
			centerYAnchor.constraint(equalTo: otherView.centerYAnchor)
		]
	}
	
	func constrainToFillView(_ otherView: UIView, respectingLayoutMargins: Bool = false) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(constraintsToFillView(otherView, respectingLayoutMargins: respectingLayoutMargins))
	}
	
	func constrainToFillViewVertically(_ otherView: UIView, respectingLayoutMargins: Bool = false) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(constraintsToFillViewVertically(otherView, respectingLayoutMargins: respectingLayoutMargins))
	}
	
	func constrainToFillViewHorizontally(_ otherView: UIView, respectingLayoutMargins: Bool = false) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(constraintsToFillViewHorizontally(otherView, respectingLayoutMargins: respectingLayoutMargins))
	}
	
	func constrainToBeCenteredInView(_ otherView: UIView) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(constraintsToBeCenteredInView(otherView))
	}
}
