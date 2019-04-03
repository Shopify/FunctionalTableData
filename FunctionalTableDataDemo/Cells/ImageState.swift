//
//  ImageState.swift
//  Shopify
//
//  Created by Raul Riera on 2017-10-13.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

public typealias ImageCell = HostCell<UIImageView, ImageState, LayoutMarginsTableItemLayout>
public typealias ImageWithSubtitleCell = CombinedCell<UIImageView, ImageState, SubtitleView, SubtitleState, LayoutMarginsTableItemLayout>

public protocol ImageLoadable {
	func setImage(from: URL, placeholder: UIImage?)
	func cancelLoadingImage()
}

public struct ImageState: Equatable {
	private static let widthAnchorIdentifier = "ImageState.Width"
	private static let heightAnchorIdentifier = "ImageState.Height"
	
	let image: UIImage?
	let url: URL?
	let width: CGFloat?
	let height: CGFloat?
	
	public init(image: UIImage, width: CGFloat?, height: CGFloat?) {
		self.image = image
		self.url = nil
		self.width = width
		self.height = height
	}
	
	public init(url: URL, width: CGFloat?, height: CGFloat?) {
		self.image = nil
		self.url = url
		self.width = width
		self.height = height
	}
	
	static func updateView(_ view: UIImageView & ImageLoadable, state: ImageState?) {
		guard let state = state else {
			view.cancelLoadingImage()
			view.image = nil
			
			return
		}
		
		let constraints = view.constraints.filter { $0.identifier == ImageState.widthAnchorIdentifier || $0.identifier == ImageState.heightAnchorIdentifier }
		constraints.forEach { $0.isActive = false }
		
		if let width = state.width {
			let widthConstraint = view.widthAnchor.constraint(equalToConstant: width)
			widthConstraint.isActive = true
			widthConstraint.identifier = ImageState.widthAnchorIdentifier
		}
	
		if let height = state.height {
			let heightConstraint = view.heightAnchor.constraint(equalToConstant: height)
			heightConstraint.isActive = true
			heightConstraint.identifier = ImageState.heightAnchorIdentifier
		}
		
		view.contentMode = .scaleAspectFit
		
		if let url = state.url {
			view.setImage(from: url, placeholder: nil)
		} else {
			view.image = state.image
		}
	}
	
	public static func ==(lhs: ImageState, rhs: ImageState) -> Bool {
		return lhs.url == rhs.url && lhs.width == rhs.width && lhs.height == rhs.height
	}
}
