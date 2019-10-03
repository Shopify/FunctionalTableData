//
//  UITableView+Reusable.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-10-08.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import UIKit

public extension UITableView {
	// MARK: Headers
	
	final func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerType: T.Type) {
		register(headerType.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
	}
	
	final func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ headerType: T.Type = T.self) -> T {
		guard let header = self.dequeueReusableHeaderFooterView(withIdentifier: headerType.reuseIdentifier) as? T else {
			fatalError("Failed to dequeue a header/footer with identifier \(headerType.reuseIdentifier) matching type \(headerType.self)")
		}
		return header
	}
	
	// MARK: Cells
	
	final func registerReusableCell<T: UITableViewCell>(_ cellType: T.Type) {
		register(cellType.self, forCellReuseIdentifier: T.reuseIdentifier)
	}
	
	final func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type = T.self, indexPath: IndexPath?) -> T {
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
