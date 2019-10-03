//
//  TableCell.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-09-10.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

public class TableCell<ViewType: UIView, Layout: TableItemLayout>: UITableViewCell {
	public let view: ViewType
	public var prepare: ((_ view: ViewType) -> Void)?
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		view = ViewType()
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		contentView.addSubviewsForAutolayout(view)
		Layout.layoutView(view, inContentView: contentView)
	}
	
	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		prepare?(view)
		prepare = nil
	}
	
	public override func accessibilityElementCount() -> Int {
		let originalCount = super.accessibilityElementCount()
		
		// Instances of a UITableViewCell subclass that don't contain any accessible views will still report
		// that they contain a single empty static text element that has no label, value or accessibility content.
		// This element does nothing and isn't read out - but it still acts as an accessible element and clutters up
		// VoiceOver navigation. The code below is a workaround to suppress these bogus accessibility placeholders.
		
		// (Instances of *UITableViewCell itself* do not exhibit this behaviour: they report no elements in this situation.
		// The mere act of subclassing UITableViewCell is enough to change the behaviour. Thanks UIKit.)
		if let element = super.accessibilityElement(at: 0) as? UIAccessibilityElement, originalCount == 1 && element.isEmpty {
			return 0
		} else {
			return originalCount
		}
	}
}

private extension UIAccessibilityElement {
	var isEmpty: Bool {
		return
			accessibilityTraits == UIAccessibilityTraits.staticText &&
				(accessibilityLabel == nil || accessibilityLabel!.isEmpty) &&
				(accessibilityValue == nil || accessibilityValue!.isEmpty) &&
				(accessibilityHint == nil || accessibilityHint!.isEmpty)
	}
}

public class TableHeaderFooter<ViewType: UIView, Layout: TableItemLayout>: UITableViewHeaderFooterView {
	public let view: ViewType
	public let topSeparator = Separator(style: Separator.Style.full)
	public let bottomSeparator = Separator(style: Separator.Style.full)
	
	public override init(reuseIdentifier: String?) {
		view = ViewType()
		super.init(reuseIdentifier: reuseIdentifier)
		
		contentView.backgroundColor = UIColor.white
		contentView.layoutMargins = view.layoutMargins
		view.layoutMargins = .zero
		contentView.addSubviewsForAutolayout(view)
		
		addSubviewsForAutolayout(topSeparator, bottomSeparator)
		topSeparator.constrainToTopOfView(self)
		bottomSeparator.constrainToBottomOfView(self)
		
		Layout.layoutView(view, inContentView: contentView)
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
