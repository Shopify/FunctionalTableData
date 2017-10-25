import Foundation
import FunctionalTableData

public typealias LabelCell = HostCell<UILabel, LabelState, LayoutMarginsTableItemLayout>

/// A very simple state for a `UILabel` allowing a quick configuration of its text, font, and color values.
public struct LabelState: Equatable {
	public let text: String
	public let font: UIFont
	public let color: UIColor
	
	public init(text: String, font: UIFont = UIFont.systemFont(ofSize: 17), color: UIColor = .black) {
		self.text = text
		self.font = font
		self.color = color
	}
	
	/// Update the view with the contents of the state.
	///
	/// - Parameters:
	///   - view: `UIView` that responds to this state.
	///   - state: data to update the view with. If `nil` the view is being reused by the tableview.
	public static func updateView(_ view: UILabel, state: LabelState?) {
		guard let state = state else {
			view.text = nil
			view.font = UIFont.systemFont(ofSize: 17)
			view.textColor = .black
			return
		}
		
		view.text = state.text
		view.font = state.font
		view.textColor = state.color
	}
	
	public static func ==(lhs: LabelState, rhs: LabelState) -> Bool {
		return lhs.text == rhs.text && lhs.font == rhs.font && lhs.color == rhs.color
	}
}
