//
//  TableItemConfigType.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-10-08.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import UIKit

public protocol TableItemConfigType {
	func register(with tableView: UITableView)
	func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
}

extension TableItemConfigType {
	public func dequeueCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
	}
}
