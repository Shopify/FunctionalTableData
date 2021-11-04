//
//  DiffableDataSourceFunctionalCollectionDataDiffer.swift
//  FunctionalTableData
//
//  Created by Jason Kemp on 2021-10-27.
//  Copyright © 2021 Shopify. All rights reserved.

import UIKit

@available(iOS 13.0, *)
final class DiffableDataSourceFunctionalCollectionDataDiffer: FunctionalCollectionDataDiffer {
	let name: String
	let data: CollectionData
	var sections: [CollectionSection] { data.sections }
	var isRendering: Bool = false
	var dataSource: UICollectionViewDiffableDataSource<AnyCollectionSection,AnyHashableConfig>!
	var collectionView: UICollectionView? {
		didSet {
			guard let collectionView = collectionView else { return }
			let dataSource = UICollectionViewDiffableDataSource<AnyCollectionSection, AnyHashableConfig>(collectionView: collectionView) { collectionView, indexPath, cellConfig in
				let section = self.data.sections[indexPath.section]
				let cell = cellConfig.dequeueCell(from: collectionView, at: indexPath)
				let accessibilityIdentifier = ItemPath(sectionKey: section.key, itemKey: cellConfig.key).description
				cellConfig.accessibility.with(defaultIdentifier: accessibilityIdentifier).apply(to: cell)
				cellConfig.update(cell: cell, in: collectionView)
				let style = cellConfig.style ?? CellStyle()
				style.configure(cell: cell, at: indexPath, in: collectionView)
				section.prepareCell(cell, in: collectionView, for: indexPath)
				return cell
			}
			dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
				let kind = ReusableKind(kind)
				// we need to check the global header/footer first, because the collectionView will request them without a "valid" indexPath.
				// there's a crashing exception or an assertion failure if we have an indexPath with only one index and call IndexPath.section
				if let header = self.data.header, kind == header.kind {
					let headerView = header.dequeueView(collectionView: collectionView, indexPath: indexPath)
					header.update(headerView, collectionView: collectionView, forIndex: -1)
					return headerView
				}
				if let footer = self.data.footer, kind == footer.kind {
					let footerView = footer.dequeueView(collectionView: collectionView, indexPath: indexPath)
					footer.update(footerView, collectionView: collectionView, forIndex: -1)
					return footerView
				}
				let sectionData = self.data.sections[indexPath.section]
				guard let reusableKindConfig = sectionData.supplementaryConfig(ofKind: kind) else {
					fatalError("We MUST return a non-null UICollectionReusableView that was previously registered with the collectionView. There's a crash otherwise. If you're seeing this error, check to see if you have registered a view of kind \(kind).")
				}
				let reusableView = reusableKindConfig.dequeueView(collectionView: collectionView, indexPath: indexPath)
				reusableKindConfig.update(reusableView, collectionView: collectionView, forIndex: indexPath.item)
				return reusableView
			}
			self.dataSource = dataSource
		}
	}

	func renderAndDiff(_ newSections: [CollectionSection], animated: Bool, completion: (() -> Void)?) {
		isRendering = true
		let indexPaths = collectionView?.indexPathsForVisibleItems ?? []
		let localSections = newSections.filter { $0.items.count > 0 }
		collectionView?.registerCellsForSections(localSections)
		let oldSections = data.sections
		let changeSet = CollectionSectionChangeSet(old: oldSections, new: localSections, visibleIndexPaths: indexPaths)
		data.sections = localSections
		
		var snapshot = NSDiffableDataSourceSnapshot<AnyCollectionSection, AnyHashableConfig>()
		let sections = localSections.map { AnyCollectionSection($0) }
		snapshot.appendSections(sections)
		for newSection in sections {
			snapshot.appendItems(newSection.items.map { AnyHashableConfig($0) }, toSection: newSection)
		}
		var isFirstRender: Bool = false
		if let snapshot = dataSource?.snapshot(), snapshot.numberOfSections == 0 {
			isFirstRender = true
		}
		let shouldAnimate = animated && !isFirstRender
		NSException.catchAndHandle {
			self.dataSource?.apply(snapshot, animatingDifferences: shouldAnimate, completion: completion)
		} failure: { exception in
			if exception.name == NSExceptionName.internalInconsistencyException {
				
				dumpDebugInfoForChanges(changeSet,
										previousSections: oldSections,
										visibleIndexPaths: indexPaths,
										exceptionReason: exception.reason,
										exceptionUserInfo: exception.userInfo)
			}
		}

	}
	
	init(name: String, data: CollectionData) {
		self.name = name
		self.data = data
	}
	
	private func dumpDebugInfoForChanges(_ changes: CollectionSectionChangeSet, previousSections: [CollectionSection], visibleIndexPaths: [IndexPath], exceptionReason: String?, exceptionUserInfo: [AnyHashable: Any]?) {
		guard let exceptionHandler = FunctionalCollectionData.exceptionHandler else { return }
		let exception = FunctionalCollectionData.Exception(name: name, newSections: sections, oldSections: previousSections, changes: changes, visible: visibleIndexPaths, viewFrame: collectionView?.frame ?? .zero, reason: exceptionReason, userInfo: exceptionUserInfo)
		exceptionHandler.handle(exception: exception)
	}
}
