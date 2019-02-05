//
//  TableSectionHeaderFooter.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-09-10.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

// MARK: Header specific item config

@available(*, deprecated: 1.0, message: "Use `TableHeaderFooterConfigType` instead.")
public typealias TableHeaderConfigType = TableHeaderFooterConfigType

public protocol TableHeaderFooterConfigType: TableItemConfigType {
	var height: CGFloat { get }
	func dequeueHeaderFooter(from tableView: UITableView) -> UITableViewHeaderFooterView?
	func isEqual(_ other: TableHeaderFooterConfigType?) -> Bool
	func debugInfo() -> [String: Any]
}

public protocol TableHeaderFooterStateType: Equatable {
	var insets: UIEdgeInsets { get }
	var height: CGFloat { get }
	var topSeparatorHidden: Bool { get }
	var bottomSeparatorHidden: Bool { get }
}

public struct TableSectionHeaderFooter<View: UIView, Layout: TableItemLayout, State: TableHeaderFooterStateType>: TableHeaderFooterConfigType {
	public typealias ViewUpdater = (_ header: TableHeaderFooter<View, Layout>, _ state: State) -> Void
	public let state: State?
	public let viewUpdater: ViewUpdater?

	public var height: CGFloat {
		return state?.height ?? 0
	}

	public init(state: State? = nil, viewUpdater: ViewUpdater? = nil) {
		self.state = state
		self.viewUpdater = viewUpdater
	}
	
	public func register(with tableView: UITableView) {
		tableView.registerReusableHeaderFooterView(TableHeaderFooter<View, Layout>.self)
	}
	
	public func dequeueHeaderFooter(from tableView: UITableView) -> UITableViewHeaderFooterView? {
		let header = tableView.dequeueReusableHeaderFooterView(TableHeaderFooter<View, Layout>.self)
		if let viewUpdater = viewUpdater, let state = state {
			viewUpdater(header, state)
		}
		return header
	}

	public func isEqual(_ other: TableHeaderFooterConfigType?) -> Bool {
		if let other = other as? TableSectionHeaderFooter<View, Layout, State> {
			return state == other.state
		}
		return false
	}

	public func debugInfo() -> [String: Any] {
		var debugInfo: [String: Any] = [:]
		if let state = state {
			debugInfo["state"] = String(describing: state)
		}
		return debugInfo
	}
}
