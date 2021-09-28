//
//  SupplementaryConfig.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-10-01.
//  Copyright © 2021 Shopify. All rights reserved.

import UIKit

public struct Supplementary<View>: CollectionSupplementaryItemConfig where View: UICollectionReusableView {
	public let kind: ReusableKind
	
	public init(kind: ReusableKind) {
		self.kind = kind
	}
	
	public func register(with collectionView: UICollectionView) {
		collectionView.register(View.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: View.reuseIdentifier)
	}
	
	public func dequeueView(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView {
		collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: View.reuseIdentifier, for: indexPath)
	}
	
	public func update(_ view: UICollectionReusableView, collectionView: UICollectionView, forIndex index: Int) {
		//intentionally blank
	}
	
	public func isEqual(_ other: CollectionSupplementaryItemConfig?) -> Bool {
		guard let other = other as? Supplementary<View> else { return false }
		return kind == other.kind
	}
}

public struct SupplementaryConfig<View, State>: CollectionSupplementaryItemConfig, Hashable where View: UIView & ConfigurableView, State: Hashable, View.State == State {
	public static func ==(lhs: SupplementaryConfig<View, State>, rhs: SupplementaryConfig<View, State>) -> Bool {
		lhs.state == rhs.state && lhs.kind == rhs.kind
	}
	
	public let state: State
	private let supplementary: Supplementary<ReusableSupplementaryView<View>>
	
	public init(kind: ReusableKind, state: State) {
		self.supplementary = Supplementary<ReusableSupplementaryView<View>>(kind: kind)
		self.state = state
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(kind)
		hasher.combine(state)
	}
	
	public var kind: ReusableKind { supplementary.kind }
	
	public func register(with collectionView: UICollectionView) {
		supplementary.register(with: collectionView)
	}
	
	public func dequeueView(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView {
		supplementary.dequeueView(collectionView: collectionView, indexPath: indexPath)
	}
	
	public func update(_ view: UICollectionReusableView, collectionView: UICollectionView, forIndex index: Int) {
		guard let view = view as? ReusableSupplementaryView<View> else { return }
		view.view.configure(state)
	}
	
	public func isEqual(_ other: CollectionSupplementaryItemConfig?) -> Bool {
		guard let other = other as? SupplementaryConfig<View, State> else { return false }
		return supplementary.isEqual(other.supplementary) && state == other.state
	}
}

public struct IndexableSupplementaryConfig<View, State>: CollectionSupplementaryItemConfig, Hashable where View: UIView & ConfigurableView, State: Hashable, View.State == State {
	public static func == (lhs: IndexableSupplementaryConfig<View, State>, rhs: IndexableSupplementaryConfig<View, State>) -> Bool {
		lhs.state == rhs.state && lhs.kind == rhs.kind
	}
		
	public let state: [State]
	public let hideLast: Bool
	private let supplementary: Supplementary<ReusableSupplementaryView<View>>
		
	public init(kind: ReusableKind, state: [State], hideLast: Bool = true) {
		self.supplementary = Supplementary<ReusableSupplementaryView<View>>(kind: kind)
		self.state = state
		self.hideLast = hideLast
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(kind)
		hasher.combine(state)
	}
	
	public var kind: ReusableKind { supplementary.kind }
	
	public func register(with collectionView: UICollectionView) {
		supplementary.register(with: collectionView)
	}
	
	public func dequeueView(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView {
		supplementary.dequeueView(collectionView: collectionView, indexPath: indexPath)
	}
	
	public func update(_ view: UICollectionReusableView, collectionView: UICollectionView, forIndex index: Int) {
		guard let view = view as? ReusableSupplementaryView<View>, state.indices.contains(index) else { return }
		view.isHidden = false
		if state.indices.endIndex - 1 == index, hideLast {
			view.isHidden = true
		} else {
			view.view.configure(state[index])
		}
	}
	
	public func isEqual(_ other: CollectionSupplementaryItemConfig?) -> Bool {
		guard let other = other as? IndexableSupplementaryConfig<View, State> else { return false }
		return supplementary.isEqual(other.supplementary) && state == other.state
	}
}
