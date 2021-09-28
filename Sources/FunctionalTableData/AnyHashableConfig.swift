//
//  AnyHashableConfig.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-10-27.
//

import UIKit

public struct AnyHashableConfig: Hashable, HashableCellConfigType {
	public static func ==(lhs: AnyHashableConfig, rhs: AnyHashableConfig) -> Bool {
		return lhs.hashable == rhs.hashable
	}
	
	private var base: CellConfigType
	public let hashable: AnyHashable
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(hashable)
	}
	
	public init(_ base: CellConfigType, sectionKey: String) {
		self.base = base
		if let hashableConfig = base as? HashableCellConfigType {
			self.hashable = hashableConfig.hashable
		} else {
			self.hashable = AnyHashable(ItemPath(sectionKey: sectionKey, itemKey: base.key))
		}
	}
	
	public init(_ base: HashableCellConfigType) {
		self.base = base
		self.hashable = base.hashable
	}
	
	public var key: String {
		return base.key
	}
	
	public var style: CellStyle? {
		get { return base.style }
		set { base.style = newValue }
	}
	
	public var actions: CellActions {
		get { return base.actions }
		set { base.actions = newValue }
	}
	
	public var accessibility: Accessibility {
		get { return base.accessibility }
		set { base.accessibility = newValue }
	}
	
	public func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		return base.dequeueCell(from: tableView, at: indexPath)
	}
	
	public func dequeueCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
		return base.dequeueCell(from: collectionView, at: indexPath)
	}
	
	public func update(cell: UITableViewCell, in tableView: UITableView) {
		base.update(cell: cell, in: tableView)
	}
	
	public func update(cell: UICollectionViewCell, in collectionView: UICollectionView) {
		base.update(cell: cell, in: collectionView)
	}
	
	public func isEqual(_ other: CellConfigType) -> Bool {
		guard let other = other as? AnyHashableConfig else { return false }
		return base.isEqual(other.base)
	}
	
	public func isSameKind(as other: CellConfigType) -> Bool {
		return base.isSameKind(as: other)
	}
	
	public func debugInfo() -> [String : Any] {
		return base.debugInfo()
	}
	
	public func register(with tableView: UITableView) {
		base.register(with: tableView)
	}
	
	public func register(with collectionView: UICollectionView) {
		base.register(with: collectionView)
	}
}
