//
//  TableSection.swift
//  FunctionalTableData
//
//  Created by Kevin Barnes on 2016-06-02.
//  Copyright © 2016 Shopify. All rights reserved.
//

import Foundation

/// A type with the information about a section.
///
/// `FunctionalTableData` deals in arrays of `TableSection` instances. Each section, at a minimum, has a string value unique within the table itself, and an array of `CellConfigType` instances that represent the rows of the section. Additionally there may be a header and footer for the section.
public protocol TableSectionType {
	/// Unique identifier for the section.
	var key: String { get }
	/// View object to display in the header of this section.
	var header: TableHeaderConfigType? { get }
	/// View object to display in the footer of this section.
	var footer: TableItemConfigType? { get }
	/// Instances of `CellConfigType` that represent the rows in the table view.
	var rows: [CellConfigType] { get }
	/// Action to perform when the header view comes in or out of view.
	var headerVisibilityAction: ((_ view: UIView, _ visible: Bool) -> Void)? { get }
	@available(*, deprecated: 1.0, message: "Use `rows.count` instead.")
	var rowCount: Int { get }

	subscript(index: Int) -> CellConfigType { get }
}

public struct TableSection: Sequence, TableSectionType {
	public let key: String
	public var header: TableHeaderConfigType? = nil
	public var footer: TableItemConfigType? = nil
	public var rows: [CellConfigType]
	/// Specifies visual attributes to be applied to the section. This includes row separators to use at the top, bottom, and between items of the section.
	public var style: SectionStyle?
	public var headerVisibilityAction: ((_ view: UIView, _ visible: Bool) -> Void)? = nil
	/// Callback executed when a row is manually moved by the user. It specifies the before and after index position.
	public var didMoveRow: ((_ from: Int, _ to: Int) -> Void)?

	public init(key: String, rows: [CellConfigType] = [], header: TableHeaderConfigType? = nil, footer: TableItemConfigType? = nil, style: SectionStyle? = nil, didMoveRow: ((_ from: Int, _ to: Int) -> Void)? = nil) {
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
	func sectionKeyPathForRow(_ index: Int) -> String? {
		guard index < rows.count else { return nil }
		return key + rows[index].key
	}

	/// Attempts to merge the separator's style provided by a `TableSection` with the separator's style provided by an instance of `CellConfigType`.
	///
	/// - Parameter row: Integer identifying the position of the row in the section.
	/// - Returns: The `CellStyle` of the cell merged with the style of the section.
	public func mergedStyle(for row: Int) -> CellStyle? {
		var rowStyle = rows[row].style

		if rowStyle == nil && style != nil {
			rowStyle = CellStyle()
		}

		switch (row, rows.index(after: row)) {
		case (rows.startIndex, rows.endIndex):
			rowStyle?.topSeparator = rowStyle?.topSeparator ?? style?.separators.top
			rowStyle?.bottomSeparator = rowStyle?.bottomSeparator ?? style?.separators.bottom
		case (rows.startIndex, _):
			rowStyle?.topSeparator = rowStyle?.topSeparator ?? style?.separators.top
			rowStyle?.bottomSeparator = rowStyle?.bottomSeparator ?? style?.separators.interitem
		case (_, rows.endIndex):
			rowStyle?.bottomSeparator = rowStyle?.bottomSeparator ?? style?.separators.bottom
		case (_, _):
			rowStyle?.bottomSeparator = rowStyle?.bottomSeparator ?? style?.separators.interitem
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
	public init<T: RawRepresentable>(key: T, rows: [CellConfigType] = [], header: TableHeaderConfigType? = nil, footer: TableItemConfigType? = nil, style: SectionStyle? = nil, didMoveRow: ((_ from: Int, _ to: Int) -> Void)? = nil) where T.RawValue == String {
		self.init(key: key.rawValue, rows: rows, header: header, footer: footer, style: style, didMoveRow: didMoveRow)
	}
}

extension Array where Element: TableSectionType {
	subscript(key: IndexPath) -> CellConfigType? {
		guard (key as NSIndexPath).section < count else { return nil }
		let row = (key as NSIndexPath).row
		let section: TableSectionType = self[(key as NSIndexPath).section]
		return (row < section.rows.count) ? section[row] : nil
	}
}

extension TableSection: Equatable {
	public static func ==(lhs: TableSection, rhs: TableSection) -> Bool {
		return lhs.key == rhs.key
	}
}
