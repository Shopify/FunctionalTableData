//
//  ControlText.swift
//  Shopify
//
//  Created by Geoffrey Foster on 2016-05-19.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

public enum TruncationStyle: String, Encodable {
	case truncate
	case multiline
}

public enum ControlText: Encodable {
	case plain(String)
	case attributed(NSAttributedString)
	
	public func encode(to encoder: Encoder) throws {
		switch self {
		case .plain(let string):
			try "plain: \(string)".encode(to: encoder)
		case .attributed(let attributedString):
			try "attributed: \(attributedString.string)".encode(to: encoder)
		}
	}
}

extension ControlText: Equatable {
	public static func ==(lhs: ControlText, rhs: ControlText) -> Bool {
		if case .plain(let value1) = lhs, case .plain(let value2) = rhs {
			return value1 == value2
		} else if case .attributed(let value1) = lhs, case .attributed(let value2) = rhs {
			return value1 == value2
		}
		return false
	}
}

public extension ControlText {
	var plainText: String {
		switch self {
		case .plain(let value):
			return value
		case .attributed(let value):
			return value.string
		}
	}
	
	var attributedText: NSAttributedString {
		switch self {
		case .plain(let value):
			return NSAttributedString(string: value)
		case .attributed(let value):
			return value
		}
	}
}

public extension UILabel {
	func setControlText(_ controlText: ControlText?) {
		if let controlText = controlText {
			switch controlText {
			case .plain(let value):
				self.text = value
			case .attributed(let value):
				self.attributedText = value
			}
		} else {
			self.text = nil
		}
	}
	
	func apply(truncationStyle: TruncationStyle) {
		switch truncationStyle {
		case .truncate:
			lineBreakMode = .byTruncatingTail
			numberOfLines = 1
		case .multiline:
			lineBreakMode = .byWordWrapping
			numberOfLines = 0
		}
	}
}

public extension UITextField {
	func setControlText(_ controlText: ControlText?) {
		if let controlText = controlText {
			switch controlText {
			case .plain(let value):
				self.text = value
			case .attributed(let value):
				self.attributedText = value
			}
		} else {
			self.text = nil
		}
	}
	
	func setControlTextPlaceholder(_ controlText: ControlText?) {
		if let controlText = controlText {
			switch controlText {
			case .plain(let value):
				self.placeholder = value
			case .attributed(let value):
				self.attributedPlaceholder = value
			}
		} else {
			self.placeholder = nil
		}
	}
}

public extension UIButton {
	func setControlText(_ controlText: ControlText?, forState state: UIControl.State) {
		if let controlText = controlText {
			switch controlText {
			case .plain(let value):
				setTitle(value, for: state)
			case .attributed(let value):
				setAttributedTitle(value, for: state)
			}
		} else {
			setTitle(nil, for: state)
			setAttributedTitle(nil, for: state)
		}
	}
}
