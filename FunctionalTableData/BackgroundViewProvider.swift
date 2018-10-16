//
//  BackgroundViewProvider.swift
//  FunctionalTableData
//
//  Created by Scott Campbell on 2018-10-16.
//  Copyright © 2018 Shopify. All rights reserved.
//

import UIKit

/// Provide a background view to be displayed behind the other contents of a cell.
/// An implementation should maintain some internal state about the contents of the view.
public protocol BackgroundViewProvider {
	/// This is where the background view should be instantiated, since this
	/// function is only called when a cell is being prepared to be deqeueued.
	func backgroundView() -> UIView?

	/// Compare the internal state to avoid unnecessarily instantiating the background view.
	func isEqualTo(_ other: BackgroundViewProvider) -> Bool
}

public extension BackgroundViewProvider {
	public func isEqualTo(_ other: BackgroundViewProvider) -> Bool {
		return type(of: self) == type(of: other)
	}
}

public struct EmptyBackgroundProvider: BackgroundViewProvider {
	public init() {}

	public func backgroundView() -> UIView? {
		return nil
	}
}
