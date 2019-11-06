//
//  TableSection.swift
//  FunctionalTableData
//
//  Created by Kevin Barnes on 2016-06-02.
//  Copyright © 2016 Shopify. All rights reserved.
//

import UIKit

/// A type that provides the information about a section.
public protocol TableSectionType {
	/// Unique identifier for the section.
	var key: String { get }
	/// View object to display in the header of this section.
	var header: TableHeaderFooterConfigType? { get }
	/// View object to display in the footer of this section.
	var footer: TableHeaderFooterConfigType? { get }
	/// Instances of `CellConfigType` that represent the items in the table.
	var rows: [CellConfigType] { get }
	/// Action to perform when the header view comes in or out of view.
	var headerVisibilityAction: ((_ view: UIView, _ visible: Bool) -> Void)? { get }
	@available(*, deprecated, message: "Use `rows.count` instead.")
	var rowCount: Int { get }

	subscript(index: Int) -> CellConfigType { get }
}

/// Defines the style, and state information of a section.
///
/// `FunctionalTableData` deals in arrays of `TableSection` instances. Each section, at a minimum, has a string value unique within the table itself, and an array of `CellConfigType` instances that represent the items of the section. Additionally there may be a header and footer for the section.
public struct TableSection: Sequence, TableSectionType {
	public let key: String
	public var header: TableHeaderFooterConfigType? = nil
	public var footer: TableHeaderFooterConfigType? = nil
	public var rows: [CellConfigType]
	/// Specifies visual attributes to be applied to the section. This includes item separators to use at the top, bottom, and between items of the section.
	public var style: SectionStyle?
	public var headerVisibilityAction: ((_ view: UIView, _ visible: Bool) -> Void)? = nil
	/// Callback executed when a item is manually moved by the user. It specifies the before and after index position.
	public var didMoveRow: ((_ from: Int, _ to: Int) -> Void)?

	public init(key: String, rows: [CellConfigType] = [], header: TableHeaderFooterConfigType? = nil, footer: TableHeaderFooterConfigType? = nil, style: SectionStyle? = nil, didMoveRow: ((_ from: Int, _ to: Int) -> Void)? = nil) {
		self.key = key
		self.rows = rows
		self.header = header
		self.footer = footer
		self.style = style
		self.didMoveRow = didMoveRow
	}

	public subscript(index: Int) -> CellConfigType {
		return rows[index]
	}

	/// Adds a row to the end of the array of rows.
	///
	/// - Parameter row: `CellConfigType` instance to append the array of rows.
	public mutating func append(_ row: CellConfigType) {
		rows.append(row)
	}

	public var rowCount: Int {
		return rows.count
	}

	public func makeIterator() -> AnyIterator<CellConfigType> {
		var nextIndex = rows.startIndex

		return AnyIterator {
			if nextIndex >= self.rows.endIndex {
				return nil as CellConfigType?
			}
			let item = self.rows[nextIndex]
			nextIndex += 1
			return item
		}
	}

	/// Returns the key identifier from its index position.
	///
	/// - Parameter index: Integer identifying the position of the row in the section.
	/// - Returns: The String identifier of the section enclosing the row.
	func sectionKeyPathForRow(_ index: Int) -> ItemPath? {
		guard index < rows.count else { return nil }
		return ItemPath(sectionKey: key, itemKey: rows[index].key)
	}

	/// Attempts to merge the separator's style provided by a `TableSection` with the separator's style provided by an instance of `CellConfigType`.
	///
	/// - Parameter row: Integer identifying the position of the row in the section.
	/// - Returns: The `CellStyle` of the cell merged with the style of the section.
	public func mergedStyle(for row: Int) -> CellStyle {
		var rowStyle = rows[row].style ?? CellStyle()

		let top = rowStyle.topSeparator ?? style?.separators.top
		let bottom = rowStyle.bottomSeparator ?? style?.separators.bottom
		let interitem = rowStyle.bottomSeparator ?? style?.separators.interitem
		
		switch (row, rows.index(after: row)) {
		case (rows.startIndex, rows.endIndex):
			rowStyle.topSeparator = top
			rowStyle.bottomSeparator = bottom
		case (rows.startIndex, _):
			rowStyle.topSeparator = top
			rowStyle.bottomSeparator = interitem
		case (_, rows.endIndex):
			rowStyle.bottomSeparator = bottom
		case (_, _):
			rowStyle.bottomSeparator = interitem
		}

		return rowStyle
	}
}

public struct SectionStyle: Equatable {
	public struct Separators: Equatable {
		public static let `default` = Separators(top: .full, bottom: .full, interitem: .inset)
		public static let topAndBottom = Separators(top: .full, bottom: .full, interitem: nil)
		public static let full = Separators(top: .full, bottom: .full, interitem: .full)
		
		public var top: Separator.Style?
		public var bottom: Separator.Style?
		public var interitem: Separator.Style?
		
		public init(top: Separator.Style? = nil, bottom: Separator.Style? = nil, interitem: Separator.Style? = nil) {
			self.top = top
			self.bottom = bottom
			self.interitem = interitem
		}
		
		public static func ==(lhs: Separators, rhs: Separators) -> Bool {
			return lhs.top == rhs.top &&
				lhs.bottom == rhs.bottom &&
				lhs.interitem == rhs.interitem
		}
	}
	public var separators: Separators
	
	public init(separators: Separators) {
		self.separators = separators
	}
	
	public static func ==(lhs: SectionStyle, rhs: SectionStyle) -> Bool {
		return lhs.separators == rhs.separators
	}
}

extension TableSection {
	public init<T: RawRepresentable>(key: T, rows: [CellConfigType] = [], header: TableHeaderFooterConfigType? = nil, footer: TableHeaderFooterConfigType? = nil, style: SectionStyle? = nil, didMoveRow: ((_ from: Int, _ to: Int) -> Void)? = nil) where T.RawValue == String {
		self.init(key: key.rawValue, rows: rows, header: header, footer: footer, style: style, didMoveRow: didMoveRow)
	}
}

extension Array where Element: TableSectionType {
	subscript(key: IndexPath) -> CellConfigType? {
		/// Accessing `.section` or `.row` from an `IndexPath` causes a crash
		/// if it doesn't have exactly two elements.
		///
		/// This can occur with the following steps:
		///
		/// - Enable Voice Control from the iOS Settings app
		///
		/// - Navigate to a view controller that uses `FunctionalTableData`.
		/// The `tableView(_:leadingSwipeActionsConfigurationForRowAt:)` delegate
		/// method gets called with an empty index path.
		///
		/// - The FunctionalTableData implementation then calls this subscript
		/// with an empty index path.
		guard key.count == 2, key.section < count else { return nil }
		let row = key.row
		let section: TableSectionType = self[key.section]
		return (row < section.rows.count) ? section[row] : nil
	}
}

extension TableSection: Equatable {
	public static func ==(lhs: TableSection, rhs: TableSection) -> Bool {
		return lhs.key == rhs.key &&
			(lhs.header == nil && rhs.header == nil || lhs.header?.isEqual(rhs.header) ?? false) &&
			(lhs.footer == nil && rhs.footer == nil || lhs.footer?.isEqual(rhs.footer) ?? false) &&
			isEqual(lhs: lhs.rows, rhs: rhs.rows) &&
			lhs.style == rhs.style &&
			(lhs.headerVisibilityAction == nil && rhs.headerVisibilityAction == nil || lhs.headerVisibilityAction != nil && rhs.headerVisibilityAction != nil) &&
			(lhs.didMoveRow == nil && rhs.didMoveRow == nil || lhs.didMoveRow != nil && rhs.didMoveRow != nil)
	}
}

private func isEqual(lhs: [CellConfigType], rhs: [CellConfigType]) -> Bool {
	guard lhs.count == rhs.count else { return false }
	
	return zip(lhs, rhs).allSatisfy { (leftCell, rightCell) -> Bool in
		return leftCell.isEqual(rightCell)
	}
}
