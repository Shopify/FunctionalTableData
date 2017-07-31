//
//  TableSectionFooter.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-09-10.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

// MARK: Generic table item config

public protocol TableItemConfigType {
	func register(with tableView: UITableView)
	func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
}

extension TableItemConfigType {
	public func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
	}
}

// MARK: Header specific item config

public protocol TableHeaderConfigType: TableItemConfigType {
	func dequeueHeaderFooter(from tableView: UITableView) -> UITableViewHeaderFooterView?
	var height: CGFloat { get }
}

public protocol TableHeaderStateType {
	var insets: UIEdgeInsets { get }
	var height: CGFloat { get }
	var topSeparatorHidden: Bool { get }
	var bottomSeparatorHidden: Bool { get }
}

public struct TableSectionFooter<ViewType: UIView, Layout: TableItemLayout, S>: TableItemConfigType {
	public typealias ViewUpdater = (_ cell: TableCell<ViewType, Layout>, _ state: S) -> Void
	public let state: S?
	let updateView: ViewUpdater?
	
	public init(state: S? = nil, updater: ViewUpdater? = nil) {
		self.state = state
		self.updateView = updater
	}
	
	public func register(with tableView: UITableView) {
		tableView.registerReusableCell(TableCell<ViewType, Layout>.self)
	}
	
	public func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(TableCell<ViewType, Layout>.self, indexPath: indexPath)
		if let updater = updateView, let state = state {
			updater(cell, state)
		}
		return cell
	}
}

public struct TableSectionHeader<ViewType: UIView, Layout: TableItemLayout, S: TableHeaderStateType>: TableHeaderConfigType {
	public typealias ViewUpdater = (_ header: TableHeader<ViewType, Layout>, _ state: S) -> Void
	public let state: S?
	let updateView: ViewUpdater?
	
	public init(state: S? = nil, updater: ViewUpdater? = nil) {
		self.state = state
		self.updateView = updater
	}
	
	public func register(with tableView: UITableView) {
		tableView.registerReusableHeaderFooterView(TableHeader<ViewType, Layout>.self)
	}
	
	public func dequeueHeaderFooter(from tableView: UITableView) -> UITableViewHeaderFooterView? {
		let header = tableView.dequeueReusableHeaderFooterView(TableHeader<ViewType, Layout>.self)
		if let updater = updateView, let state = state {
			updater(header, state)
		}
		return header
	}
	
	public var height: CGFloat {
		return state?.height ?? 0
	}
}
