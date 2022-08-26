//
//  TableSectionHeaderFooter.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-09-10.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

// MARK: Header specific item config

@available(*, deprecated, message: "Use `TableHeaderFooterConfigType` instead.")
public typealias TableHeaderConfigType = TableHeaderFooterConfigType

public protocol TableHeaderFooterConfigType: TableItemConfigType {
	func dequeueHeaderFooter(from tableView: UITableView) -> UITableViewHeaderFooterView?
	func isEqual(_ other: TableHeaderFooterConfigType?) -> Bool
	var height: CGFloat { get }
	func height(given width: CGFloat) -> CGFloat?
}

extension TableHeaderFooterConfigType {
	public func height(given width: CGFloat) -> CGFloat? {
		nil
	}
}

public protocol TableHeaderFooterStateType: Equatable {
	var insets: UIEdgeInsets { get }
	var height: CGFloat { get }
	var topSeparatorHidden: Bool { get }
	var bottomSeparatorHidden: Bool { get }
	
	func height(given width: CGFloat) -> CGFloat?
}

extension TableHeaderFooterStateType {
	public func height(given width: CGFloat) -> CGFloat? {
		nil
	}
}

public struct TableSectionHeaderFooter<ViewType: UIView, Layout: TableItemLayout, S: TableHeaderFooterStateType>: TableHeaderFooterConfigType {
	public func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
	
	public typealias ViewUpdater = (_ header: TableHeaderFooter<ViewType, Layout>, _ state: S) -> Void
	public let state: S?
	let updateView: ViewUpdater?
	
	public init(state: S? = nil, updater: ViewUpdater? = nil) {
		self.state = state
		self.updateView = updater
	}
	
	public func register(with tableView: UITableView) {
		tableView.registerReusableHeaderFooterView(TableHeaderFooter<ViewType, Layout>.self)
	}
	
	public func dequeueHeaderFooter(from tableView: UITableView) -> UITableViewHeaderFooterView? {
		let header = tableView.dequeueReusableHeaderFooterView(TableHeaderFooter<ViewType, Layout>.self)
		if let updater = updateView, let state = state {
			updater(header, state)
		}
		return header
	}
	
	public var height: CGFloat {
		state?.height ?? 0
	}
	
	public func height(given width: CGFloat) -> CGFloat? {
		return state?.height(given: width) ?? height
	}

	// MARK: - TableHeaderFooterConfigType

	public func isEqual(_ other: TableHeaderFooterConfigType?) -> Bool {
		guard let other = other as? TableSectionHeaderFooter<ViewType, Layout, S> else { return false }
		return self.state == other.state
	}
}
