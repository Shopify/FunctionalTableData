//
//  ImageCell.swift
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-08-03.
//  Copyright © 2017 Shopify. All rights reserved.
//

import FunctionalTableData

typealias ImageCell = HostCell<UIImageView, ImageState, EdgeBasedTableItemLayout>

struct ImageState: Equatable {
	let image: UIImage

	static func updateView(_ view: UIImageView, state: ImageState?) {
		guard let state = state else {
			// State is empty, reset the view to prepare it for reuse.
			view.image = nil
			view.contentMode = .scaleToFill
			return
		}
		view.image = state.image
		view.contentMode = .scaleAspectFit
	}
	
	// MARK: Equatable
	
	static func ==(lhs: ImageState, rhs: ImageState) -> Bool {
		return lhs.image == rhs.image
	}
}
