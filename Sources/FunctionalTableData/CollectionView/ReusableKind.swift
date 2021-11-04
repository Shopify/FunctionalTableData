//
//  ReusableKind.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-10-15.
//  Copyright © 2021 Shopify. All rights reserved.

import Foundation

/// A strongly-typed identifier for supplementary view kinds.
public struct ReusableKind: Equatable, Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
	public let rawValue: String
	
	public var description: String { rawValue }
	
	public init?(rawValue: String) {
		self.rawValue = rawValue
	}
	
	public init(stringLiteral: String) {
		self.rawValue = stringLiteral
	}
	
	public init(_ value: String) {
		self.rawValue = value
	}
}

public extension ReusableKind {
	/// Represents a header supplementary view kind
	static let header: ReusableKind = "Header"
	/// Represents a footer supplementary view kind
	static let footer: ReusableKind = "Footer"
	/// Represents a separator supplymentary view kind
	static let separator: ReusableKind = "Separator"
}
