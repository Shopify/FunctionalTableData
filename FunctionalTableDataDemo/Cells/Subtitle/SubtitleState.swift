//
//  SubtitleCell.swift
//  Shopify
//
//  Created by Raul Riera on 2017-09-21.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

public typealias SubtitleCell = HostCell<SubtitleView, SubtitleState, LayoutMarginsTableItemLayout>

public struct SubtitleState: Equatable {
	let title: ControlText
	let titleTruncationStyle: TruncationStyle
	let subtitle: ControlText
	let subtitleTruncationStyle: TruncationStyle
	
	public init(title: ControlText, titleTruncationStyle: TruncationStyle = .truncate, subtitle: ControlText, subtitleTruncationStyle: TruncationStyle = .multiline) {
		self.title = title
		self.titleTruncationStyle = titleTruncationStyle
		self.subtitle = subtitle
		self.subtitleTruncationStyle = subtitleTruncationStyle
	}
	
	public static func updateView(_ view: SubtitleView, state: SubtitleState?) {
		guard let state = state else {
			// reset parts of state that need to be reset
			view.titleLabel.setControlText(nil)
			view.subtitleLabel.setControlText(nil)
			return
		}
		
		view.titleLabel.setControlText(state.title)
		view.titleLabel.apply(truncationStyle: state.titleTruncationStyle)
		view.subtitleLabel.setControlText(state.subtitle)
		view.subtitleLabel.apply(truncationStyle: state.subtitleTruncationStyle)
	}
}
