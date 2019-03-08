//
//  ScrollViewDelegate.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-03-07.
//  Copyright © 2019 Shopify. All rights reserved.
//

import Foundation

internal class ScrollViewDelegate: NSObject, UIScrollViewDelegate, UIScrollViewAccessibilityDelegate {
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll) for more information.
	var scrollViewDidScroll: ((_ scrollView: UIScrollView) -> Void)?
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619394-scrollviewwillbegindragging) for more information.
	var scrollViewWillBeginDragging: ((_ scrollView: UIScrollView) -> Void)?
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619385-scrollviewwillenddragging) for more information.
	var scrollViewWillEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)?
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619436-scrollviewdidenddragging) for more information.
	var scrollViewDidEndDragging: ((_ scrollView: UIScrollView, _ decelerate: Bool) -> Void)?
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619386-scrollviewwillbegindecelerating) for more information.
	var scrollViewWillBeginDecelerating: ((_ scrollView: UIScrollView) -> Void)?
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619417-scrollviewdidenddecelerating) for more information.
	var scrollViewDidEndDecelerating: ((_ scrollView: UIScrollView) -> Void)?
	/// Tells the delegate that the scroll view has changed its content size.
	var scrollViewDidChangeContentSize: ((_ scrollView: UIScrollView) -> Void)?
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619379-scrollviewdidendscrollinganimati) for more information.
	var scrollViewDidEndScrollingAnimation: ((_ scrollView: UIScrollView) -> Void)?
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619378-scrollviewshouldscrolltotop) for more information.
	var scrollViewShouldScrollToTop: ((_ scrollView: UIScrollView) -> Bool)?
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619382-scrollviewdidscrolltotop) for more information.
	var scrollViewDidScrollToTop: ((_ scrollView: UIScrollView) -> Void)?
	
	/// An optional callback that describes the current scroll position of the table as an accessibility aid.
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewaccessibilitydelegate/1621055-accessibilityscrollstatus) for more information.
	var scrollViewAccessibilityScrollStatus: ((_ scrollView: UIScrollView) -> String?)?
	
	/// This is an undocumented optional `UIScrollViewDelegate` method that is not exposed by the public protocol
	/// but will still get called on delegates that implement it. Because it is not publicly exposed,
	/// the Swift 4 compiler will not automatically annotate it as @objc, requiring this manual annotation.
	@objc public func scrollViewDidChangeContentSize(_ scrollView: UIScrollView) {
		scrollViewDidChangeContentSize?(scrollView)
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollViewDidScroll?(scrollView)
	}
	
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		scrollViewWillBeginDragging?(scrollView)
	}
	
	public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		scrollViewWillEndDragging?(scrollView, velocity, targetContentOffset)
	}
	
	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		scrollViewDidEndDragging?(scrollView, decelerate)
	}
	
	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		scrollViewWillBeginDecelerating?(scrollView)
	}
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		scrollViewDidEndDecelerating?(scrollView)
	}
	
	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		scrollViewDidEndScrollingAnimation?(scrollView)
	}
	
	public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		return scrollViewShouldScrollToTop?(scrollView) ?? true
	}
	
	public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
		scrollViewDidScrollToTop?(scrollView)
	}
	
	public func accessibilityScrollStatus(for scrollView: UIScrollView) -> String? {
		return scrollViewAccessibilityScrollStatus?(scrollView)
	}
}

public extension FunctionalTableData {
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll) for more information.
	public var scrollViewDidScroll: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidScroll
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidScroll = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619394-scrollviewwillbegindragging) for more information.
	public var scrollViewWillBeginDragging: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewWillBeginDragging
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewWillBeginDragging = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619385-scrollviewwillenddragging) for more information.
	public var scrollViewWillEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewWillEndDragging
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewWillEndDragging = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619436-scrollviewdidenddragging) for more information.
	public var scrollViewDidEndDragging: ((_ scrollView: UIScrollView, _ decelerate: Bool) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidEndDragging
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidEndDragging = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619386-scrollviewwillbegindecelerating) for more information.
	public var scrollViewWillBeginDecelerating: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewWillBeginDecelerating
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewWillBeginDecelerating = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619417-scrollviewdidenddecelerating) for more information.
	public var scrollViewDidEndDecelerating: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidEndDecelerating
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidEndDecelerating = newValue
		}
	}
	/// Tells the delegate that the scroll view has changed its content size.
	public var scrollViewDidChangeContentSize: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidChangeContentSize
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidChangeContentSize = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619379-scrollviewdidendscrollinganimati) for more information.
	public var scrollViewDidEndScrollingAnimation: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidEndScrollingAnimation
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidEndScrollingAnimation = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619378-scrollviewshouldscrolltotop) for more information.
	public var scrollViewShouldScrollToTop: ((_ scrollView: UIScrollView) -> Bool)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewShouldScrollToTop
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewShouldScrollToTop = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619382-scrollviewdidscrolltotop) for more information.
	public var scrollViewDidScrollToTop: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidScrollToTop
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidScrollToTop = newValue
		}
	}
	
	/// An optional callback that describes the current scroll position of the table as an accessibility aid.
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewaccessibilitydelegate/1621055-accessibilityscrollstatus) for more information.
	public var scrollViewAccessibilityScrollStatus: ((_ scrollView: UIScrollView) -> String?)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewAccessibilityScrollStatus
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewAccessibilityScrollStatus = newValue
		}
	}
}

public extension FunctionalCollectionData {
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll) for more information.
	public var scrollViewDidScroll: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidScroll
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidScroll = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619394-scrollviewwillbegindragging) for more information.
	public var scrollViewWillBeginDragging: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewWillBeginDragging
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewWillBeginDragging = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619385-scrollviewwillenddragging) for more information.
	public var scrollViewWillEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewWillEndDragging
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewWillEndDragging = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619436-scrollviewdidenddragging) for more information.
	public var scrollViewDidEndDragging: ((_ scrollView: UIScrollView, _ decelerate: Bool) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidEndDragging
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidEndDragging = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619386-scrollviewwillbegindecelerating) for more information.
	public var scrollViewWillBeginDecelerating: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewWillBeginDecelerating
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewWillBeginDecelerating = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619417-scrollviewdidenddecelerating) for more information.
	public var scrollViewDidEndDecelerating: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidEndDecelerating
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidEndDecelerating = newValue
		}
	}
	/// Tells the delegate that the scroll view has changed its content size.
	public var scrollViewDidChangeContentSize: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidChangeContentSize
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidChangeContentSize = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619379-scrollviewdidendscrollinganimati) for more information.
	public var scrollViewDidEndScrollingAnimation: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidEndScrollingAnimation
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidEndScrollingAnimation = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619378-scrollviewshouldscrolltotop) for more information.
	public var scrollViewShouldScrollToTop: ((_ scrollView: UIScrollView) -> Bool)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewShouldScrollToTop
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewShouldScrollToTop = newValue
		}
	}
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619382-scrollviewdidscrolltotop) for more information.
	public var scrollViewDidScrollToTop: ((_ scrollView: UIScrollView) -> Void)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewDidScrollToTop
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewDidScrollToTop = newValue
		}
	}
	
	/// An optional callback that describes the current scroll position of the table as an accessibility aid.
	/// See UIScrollView's [documentation](https://developer.apple.com/documentation/uikit/uiscrollviewaccessibilitydelegate/1621055-accessibilityscrollstatus) for more information.
	public var scrollViewAccessibilityScrollStatus: ((_ scrollView: UIScrollView) -> String?)? {
		get {
			return backwardsCompatScrollViewDelegate.scrollViewAccessibilityScrollStatus
		}
		set {
			backwardsCompatScrollViewDelegate.scrollViewAccessibilityScrollStatus = newValue
		}
	}
}
