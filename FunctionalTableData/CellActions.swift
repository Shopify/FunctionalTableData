//
//  CellActions.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-07-25.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation
import UIKit

/// The actions property exposed on the CellConfigType represents possible events that will be executed based on the users interaction with that particular cell. Of note are the `selectionAction` and `previewingViewControllerAction`. The `selectionAction` is executed when the user taps on that particular cell. The main use case for this is present a new detail view controller or a modal (but is not constrained to these actions, these are just the common use cases). The `previewingViewControllerAction` is responsible for returning an instance of a UIViewController that will be shown when a user 3D-touches on a cell.
public struct CellActions {
	public enum SelectionState {
		case selected
		case deselected
	}
	
	public typealias SelectionAction = (_ sender: UIView) -> SelectionState
	public typealias CanPerformAction = (_ selector: Selector) -> Bool
	public typealias VisibilityAction = (_ cell: UIView, _ visible: Bool) -> Void
	/// Closure type that is executed when the user 3D-touches on a cell
	/// - parameter cell: the cell in which the 3D-touch occured
	/// - parameter point: The point where the 3D-touch occured, translated to the coordinate space of the cell
	/// - parameter context: The instance of `UIViewControllerPreviewing` that is participating in the 3D-touch
	public typealias PreviewingViewControllerAction = (_ cell: UIView, _ point: CGPoint, _ context: UIViewControllerPreviewing) -> UIViewController?
	
	/// The action to perform when the cell is selected
	public let selectionAction: SelectionAction?
	/// All the available row actions this cell can perform. See [UITableViewRowAction](https://developer.apple.com/documentation/uikit/uitableviewrowaction) for more info.
	public let rowActions: [UITableViewRowAction]?
	/// Indicates if the cell can perform a given action.
	public let canPerformAction: CanPerformAction?
	/// Indicates if the cell can be manually moved by the user.
	public let canBeMoved: Bool
	/// The action to perform when the cell becomes visible.
	public let visibilityAction: VisibilityAction?
	/// The action to perform when the cell is 3D touched by the user.
	public let previewingViewControllerAction: PreviewingViewControllerAction?
	
	public init(selectionAction: SelectionAction? = nil,
	            rowActions: [UITableViewRowAction]? = nil,
	            canPerformAction: CanPerformAction? = nil,
	            canBeMoved: Bool = false,
	            visibilityAction: VisibilityAction? = nil,
	            previewingViewControllerAction: PreviewingViewControllerAction? = nil) {
		self.selectionAction = selectionAction
		self.rowActions = rowActions
		self.canPerformAction = canPerformAction
		self.canBeMoved = canBeMoved
		self.visibilityAction = visibilityAction
		self.previewingViewControllerAction = previewingViewControllerAction
	}
	
	public init(selectionAction: SelectionAction? = nil,
				rowActions: [UITableViewRowAction]? = nil,
				canPerformAction: CanPerformAction? = nil,
				canBeMoved: Bool = false,
				visibilityAction: VisibilityAction? = nil,
				previewingViewControllerAction: @escaping () -> UIViewController?) {
		let wrappedPreviewingViewControllerAction: PreviewingViewControllerAction = { (cell, _, previewingContext) in
			previewingContext.sourceRect = previewingContext.sourceView.convert(cell.bounds, from: cell)
			return previewingViewControllerAction()
		}
		self.init(selectionAction: selectionAction, rowActions: rowActions, canPerformAction: canPerformAction, canBeMoved: canBeMoved, visibilityAction: visibilityAction, previewingViewControllerAction: wrappedPreviewingViewControllerAction)
	}
}
