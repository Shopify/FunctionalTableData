//
//  CellActions.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-07-25.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation
import UIKit

/// The actions property exposed on the CellConfigType represents possible events that will be executed based on the users interaction with that particular cell.
public struct CellActions {
	/// Create a SwipeActionsConfiguration object to associate custom swipe actions with a row of your table view. Users swipe horizontally left or right in a table view to reveal the actions associated with a row. Each swipe-actions object contains the set of actions to display for each type of swipe.
	public struct SwipeActionsConfiguration {
		/// An action to display when the user swipes a table row.
		///
		/// Create UIContextualAction objects to define the types of actions that can be performed when the user swipes left or right on a table row.
		public struct ContextualAction {
			/// The handler block to call in response to the selection of an action
			/// - Parameters:
			///   - sourceView: The view in which the action was displayed.
			///   - completionHandler: The handler block for you to execute after you have performed the action. This block has no return value and takes the following parameter:
			///   - actionPerformed: A Boolean value indicating whether you performed the action. Specify true if you performed the action or false if you were unable to perform the action for some reason.
			public typealias Handler = (_ sourceView: UIView, _ completionHandler: (_ actionPerformed: Bool) -> Void) -> Void
			
			/// Constants indicating the style information that is applied to the action button.
			///
			/// - normal: A normal action.
			/// - destructive: An action that deletes data or performs some type of destructive task.
			public enum Style {
				case normal
				case destructive
			}
			let title: String?
			let backgroundColor: UIColor?
			let image: UIImage?
			let style: Style
			let handler: Handler
			
			/// Creates a new contextual action.
			///
			/// - Parameters:
			///   - title: The title of the action button.
			///   - backgroundColor: The background color of the action button.
			///   - image: The image to display in the action button.
			///   - style: The style information to apply to the action button.
			///   - handler: The handler to execute when the user selects the action.
			public init(title: String?, backgroundColor: UIColor? = nil, image: UIImage? = nil, style: Style, handler: @escaping Handler) {
				self.title = title
				self.backgroundColor = backgroundColor
				self.image = image
				self.style = style
				self.handler = handler
			}
			
			internal func asRowAction(in tableView: UITableView) -> UITableViewRowAction {
				let style: UITableViewRowAction.Style
				switch self.style {
				case .normal:
					style = .normal
				case .destructive:
					style = .destructive
				}
				let rowAction = UITableViewRowAction(style: style, title: title) { [handler] (_, indexPath) in
					let cell = tableView.cellForRow(at: indexPath)
					handler(cell ?? tableView) { _ in } // UITableViewRowAction doesn't support the callback based approach, so fake it instead
				}
				if let backgroundColor = backgroundColor {
					rowAction.backgroundColor = backgroundColor
				}
				return rowAction
			}
			
			@available(iOSApplicationExtension 11.0, *)
			internal func asContextualAction() -> UIContextualAction {
				let style: UIContextualAction.Style
				switch self.style {
				case .normal:
					style = .normal
				case .destructive:
					style = .destructive
				}
				let contextualAction = UIContextualAction(style: style, title: title, handler: { [handler] (_, sourceView, completionHandler) in
					handler(sourceView, completionHandler)
				})
				contextualAction.image = image
				if let backgroundColor = backgroundColor {
					contextualAction.backgroundColor = backgroundColor
				}
				
				return contextualAction
			}
		}
		
		let actions: [ContextualAction]
		let performsFirstActionWithFullSwipe: Bool

		/// Creates a swipe action configuration object with the specified set of actions.
		///
		/// - Parameters:
		///   - actions: The swipe actions.
		///   - performsFirstActionWithFullSwipe: Whether a full swipe automatically performs the first action. Defaults to `true`.
		public init(actions: [ContextualAction], performsFirstActionWithFullSwipe: Bool = true) {
			self.actions = actions
			self.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
		}
		
		func asRowActions(in tableView: UITableView) -> [UITableViewRowAction] {
			return actions.map { $0.asRowAction(in: tableView) }
		}
		
		@available(iOSApplicationExtension 11.0, *)
		func asSwipeActionsConfiguration() -> UISwipeActionsConfiguration {
			let configuration = UISwipeActionsConfiguration(actions: actions.map { $0.asContextualAction() })
			configuration.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
			return configuration
		}
	}
	/// The possible states a cell can be when a selection action is performed on it.
	public enum SelectionState {
		case selected
		case deselected
	}
	
	public typealias CanSelectCallback = (Bool) -> Void
	public typealias CanSelectAction = (_ canSelect: @escaping CanSelectCallback) -> Void
	public typealias SelectionAction = (_ sender: UIView) -> SelectionState
	public typealias DeselectionAction = (_ sender: UIView) -> SelectionState
	public typealias CanPerformAction = (_ selector: Selector) -> Bool
	public typealias VisibilityAction = (_ cell: UIView, _ visible: Bool) -> Void
	/// Closure type that is executed when the user 3D-touches on a cell
	/// - parameter cell: the cell in which the 3D-touch occured
	/// - parameter point: The point where the 3D-touch occured, translated to the coordinate space of the cell
	/// - parameter context: The instance of `UIViewControllerPreviewing` that is participating in the 3D-touch
	public typealias PreviewingViewControllerAction = (_ cell: UIView, _ point: CGPoint, _ context: UIViewControllerPreviewing) -> UIViewController?
	
	/// The action to perform when the cell will be selected.
	/// - Important: When the `canSelectAction` is called, it is passed a `CanSelectCallback` closure. It is the responsibility of the action to eventually call the passed in closure providing either a `true` or `false` value to it. This passed in value determines if the selection will be performed or not.
	public let canSelectAction: CanSelectAction?
	/// The action to perform when the cell is selected
	public let selectionAction: SelectionAction?
	/// The action to perform when the cell is deselected
	public let deselectionAction: SelectionAction?
	
	/// The swipe actions to display on the leading edge of the row.
	///
	/// Use this method to return a set of actions to display when the user swipes the row. The actions you return are displayed on the leading edge of the row. For example, in a left-to-right language environment, they are displayed on the left side of the row when the user swipes from left to right.
	public let leadingActionConfiguration: SwipeActionsConfiguration?
	
	/// The swipe actions to display next to the trailing edge of the row. Return nil if you want the table to display the default set of actions.
	///
	/// Use this method to return a set of actions to display when the user swipes the row. The actions you return are displayed on the trailing edge of the row. For example, in a left-to-right language environment, they are displayed on the right side of the row when the user swipes from right to left.
	public let trailingActionConfiguration: SwipeActionsConfiguration?
	
	/// Indicates if the cell can perform a given action.
	public let canPerformAction: CanPerformAction?
	/// Indicates if the cell can be manually moved by the user.
	public let canBeMoved: Bool
	/// The action to perform when the cell becomes visible.
	public let visibilityAction: VisibilityAction?
	/// The action to perform when the cell is 3D touched by the user.
	/// - note: By default the `UIViewControllerPreviewing` will have its `sourceRect` configured to be the entire cells frame.
	/// The given `previewingViewControllerAction` however can override this as it sees fit.
	public let previewingViewControllerAction: PreviewingViewControllerAction?
	
	public init(
		canSelectAction: CanSelectAction? = nil,
		selectionAction: SelectionAction? = nil,
		deselectionAction: DeselectionAction? = nil,
		leadingActionConfiguration: SwipeActionsConfiguration? = nil,
		trailingActionConfiguration: SwipeActionsConfiguration? = nil,
		canPerformAction: CanPerformAction? = nil,
		canBeMoved: Bool = false,
		visibilityAction: VisibilityAction? = nil,
		previewingViewControllerAction: PreviewingViewControllerAction? = nil) {
		self.canSelectAction = canSelectAction
		self.selectionAction = selectionAction
		self.deselectionAction = deselectionAction
		self.leadingActionConfiguration = leadingActionConfiguration
		self.trailingActionConfiguration = trailingActionConfiguration
		self.canPerformAction = canPerformAction
		self.canBeMoved = canBeMoved
		self.visibilityAction = visibilityAction
		if let previewingViewControllerAction = previewingViewControllerAction {
			self.previewingViewControllerAction = { (cell, point, context) in
				context.sourceRect = context.sourceView.convert(cell.bounds, from: cell)
				return previewingViewControllerAction(cell, point, context)
			}
		} else {
			self.previewingViewControllerAction = nil
		}
	}
	
	internal var hasEditActions: Bool {
		return leadingActionConfiguration != nil || trailingActionConfiguration != nil
	}
}

// MARK: - Backwards Compatible Initializers

public extension CellActions {
	/// Backwards compatible initializer that wraps the `previewingViewControllerAction` to the new form.
	@available(*, deprecated, message: "Use init with previewingViewControllerAction of type `PreviewingViewControllerAction`")
	init(
		canSelectAction: CanSelectAction? = nil,
		selectionAction: SelectionAction? = nil,
		deselectionAction: DeselectionAction? = nil,
		canPerformAction: CanPerformAction? = nil,
		canBeMoved: Bool = false,
		visibilityAction: VisibilityAction? = nil,
		previewingViewControllerAction: @escaping () -> UIViewController?) {
		let wrappedPreviewingViewControllerAction: PreviewingViewControllerAction = { (cell, _, previewingContext) in
			previewingContext.sourceRect = previewingContext.sourceView.convert(cell.bounds, from: cell)
			return previewingViewControllerAction()
		}
		self.init(
			canSelectAction: canSelectAction,
			selectionAction: selectionAction,
			deselectionAction: deselectionAction,
			leadingActionConfiguration: nil,
			trailingActionConfiguration: nil,
			canPerformAction: canPerformAction,
			canBeMoved: canBeMoved,
			visibilityAction: visibilityAction,
			previewingViewControllerAction: wrappedPreviewingViewControllerAction)
	}
}
