//
//  UIControl+Extensions.swift
//  Shopify
//
//  Created by Tom Burns on 2016-01-06.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

public protocol UIControlClosureAction {}
extension UIControl: UIControlClosureAction {}

/// An action object to be associated with the control.
public final class Action<T: UIControl>: NSObject {
	let events: UIControl.Event
	let action: (_: T) -> Void
	
	/// Initializes a new Action instance with corresponding events and action to execute.
	///
	/// - Parameters:
	///   - events: The control-specific events for which the action method is called.
	///   - action: The action that will be executed when the control fires a matching UIControlEvents value.
	///   - _: The sender of the event.
	public init(events: UIControl.Event, action: @escaping (_: T) -> Void) {
		self.events = events
		self.action = action
	}
	
	@objc dynamic fileprivate func performAction(sender: Any) {
		action(sender as! T)
	}
}

public extension UIControlClosureAction where Self: UIControl {
	/// Sets a closure to be executed when the user initiates one of the matching control events.
	///
	/// - Parameters:
	///   - events: The control-specific events for which the action method is called.
	///   - action: The action that will be executed when the control fires a matching UIControlEvents value.
	/// - Note: Calling this will remove all existing actions
	func setAction(for events: UIControl.Event, action: @escaping (_: Self) -> Void) {
		setActions([Action<Self>(events: events, action: action)])
	}
	
	/// Adds a series of actions to be executed when a corresponding control event is triggered.
	///
	/// - Parameter actions: The set of different actions to add to the control.
	/// - Note: Calling this will remove all existing actions. Passing an empty array will remove all and not add any new ones.
	func setActions(_ actions: [Action<Self>]) {
		if let oldActions = self.actions as? [Action<Self>] {
			oldActions.forEach {
				removeTarget($0, action: #selector(Action<Self>.performAction(sender:)), for: $0.events)
			}
		}
		actions.forEach {
			addTarget($0, action: #selector(Action<Self>.performAction(sender:)), for: $0.events)
		}
		self.actions = actions
	}
	
	/// Appends an action to series of existing actions
	///
	/// - Parameter actions: The action to add
	func addAction(_ action: Action<Self>) {
		addTarget(action, action: #selector(Action<Self>.performAction(sender:)), for: action.events)
		actions.append(action)
	}
}

private extension UIControl {
	private static var controlActionAssociatedHandle: UInt8 = 0
	
	var actions: [AnyObject] {
		get {
			let a = objc_getAssociatedObject(self, &UIControl.controlActionAssociatedHandle)
			return a as? [AnyObject] ?? []
		}
		set {
			objc_setAssociatedObject(self, &UIControl.controlActionAssociatedHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}
