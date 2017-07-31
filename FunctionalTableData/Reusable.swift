//
//  Reusable.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-09-10.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

/// A type that identifies a dequeueable object. Used by `FunctionalTableData` to increase performance by reusing objects when it needs to, just like `UITableView` and `UICollectionView`.
public protocol Reusable: class {
	/// Unique identifier for the object.
	static var reuseIdentifier: String { get }
}

extension Reusable {
	public static var reuseIdentifier: String {
		return NSStringFromClass(self)
	}
}

public extension UITableView {
	// MARK: Headers
	
	final func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerType: T.Type) where T: Reusable {
		register(headerType.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
	}
	
	final func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerType: T.Type = T.self) -> T where T: Reusable {
		guard let header = self.dequeueReusableHeaderFooterView(withIdentifier: headerType.reuseIdentifier) as? T else {
			fatalError("Failed to dequeue a header/footer with identifier \(headerType.reuseIdentifier) matching type \(headerType.self)")
		}
		return header
	}
	
	// MARK: Cells
	
	final func registerReusableCell<T: UITableViewCell>(_ cellType: T.Type) where T: Reusable {
		register(cellType.self, forCellReuseIdentifier: T.reuseIdentifier)
	}
	
	final func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type = T.self, indexPath: IndexPath?) -> T where T: Reusable {
		if let indexPath = indexPath {
			guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
				fatalError("Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self)")
			}
			return cell
		} else {
			guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier) as? T else {
				fatalError("Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self)")
			}
			return cell
		}
	}
}

extension UITableViewCell: Reusable { }

extension UITableViewHeaderFooterView: Reusable { }
