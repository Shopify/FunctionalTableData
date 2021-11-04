//
//  CellConfig.swift
//  
//
//  Created by Jason Kemp on 2021-10-19.
//

import UIKit

public struct CellConfig<View, State>: HashableCellConfigType where View: UIView & ConfigurableView, State: Hashable, View.State == State {
	public typealias CollectionCellType = ConfigurableCollectionCell<View, State>
	
	public let key: String
	public var hashable: AnyHashable { return AnyHashable(state) }
	public var style: CellStyle?
	public var actions: CellActions
	public var accessibility: Accessibility
	public let state: State
	
	public init(key: String,
				style: CellStyle? = CellStyle(backgroundColor: nil),
				actions: CellActions = CellActions(),
				accessibility: Accessibility = Accessibility(),
				state: State) {
		self.key = key
		self.style = style
		self.actions = actions
		self.accessibility = accessibility
		self.state = state
	}
	
	public func isEqual(_ other: CellConfigType) -> Bool {
		guard let other = other as? CellConfig<View, State> else {
			return false
		}
		return state == other.state && accessibility == other.accessibility
	}
	
	public func debugInfo() -> [String : Any] {
		return ["key": key, "type": String(describing: type(of: self))]
	}
	
	// MARK: - TableItemConfigType
	public func register(with tableView: UITableView) {
		// intentionally blank, intended use for CellConfig is for UICollectionView
	}
	
	public func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
	
	public func update(cell: UITableViewCell, in tableView: UITableView) {
		// intentionally blank, intended use for CellConfig is for UICollectionView
	}
	
	// MARK: - CollectionItemConfigType
	
	public func register(with collectionView: UICollectionView) {
		collectionView.registerReusableCell(CollectionCellType.self)
	}
	
	public func dequeueCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
		return collectionView.dequeueReusableCell(CollectionCellType.self, indexPath: indexPath)
	}
	
	public func update(cell: UICollectionViewCell, in collectionView: UICollectionView) {
		guard let cell = cell as? CollectionCellType else { return }
		cell.configure(state)
	}
}
