//
//  TableSectionChangeSet.swift
//  FunctionalTableData
//
//  Created by Bouke van der Bijl on 2017-01-18.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation

struct Moved<T: Equatable>: Equatable {
	let from: T
	let to: T

	static func ==(lhs: Moved<T>, rhs: Moved<T>) -> Bool {
		return lhs.from == lhs.from && lhs.to == rhs.to
	}
}

// Compares two arrays of TableSections and produces the operations
// required to go from one to the other
public final class TableSectionChangeSet {
	typealias MovedSection = Moved<Int>
	typealias MovedRow = Moved<IndexPath>

	var deletedSections = IndexSet()
	var insertedSections = IndexSet()
	var reloadedSections = IndexSet()
	var movedSections: [MovedSection] = []

	var deletedRows: [IndexPath] = []
	var insertedRows: [IndexPath] = []
	var reloadedRows: [IndexPath] = []
	var movedRows: [MovedRow] = []

	struct Update {
		let index: IndexPath
		let cellConfig: CellConfigType
	}
	var updates: [Update] = []

	let old: [TableSection]
	let new: [TableSection]
	let visibleIndexPaths: [IndexPath]

	public var isEmpty: Bool {
		return deletedSections.isEmpty
			&& insertedSections.isEmpty
			&& reloadedSections.isEmpty
			&& movedSections.isEmpty
			&& deletedRows.isEmpty
			&& insertedRows.isEmpty
			&& reloadedRows.isEmpty
			&& movedRows.isEmpty
			&& updates.isEmpty
	}

	public var count: Int {
		var total = deletedSections.count
		total += insertedSections.count
		total += reloadedSections.count
		total += movedSections.count
		total += deletedRows.count
		total += insertedRows.count
		total += reloadedRows.count
		total += movedRows.count
		total += updates.count
		return total
	}

	init(old: [TableSection] = [], new: [TableSection] = [], visibleIndexPaths: [IndexPath] = []) {
		self.old = old
		self.new = new
		self.visibleIndexPaths = visibleIndexPaths

		calculateChanges()
	}

	/*
	* This method calculates what set of operations are needed to go from an old list of sections to a new list of sections.
	* It does this through a greedy algorithm, that goes through both lists at the same time.
	* It won't always have the strictly optimal set of operations, because it only ever moves items up, not down.
	* As an example, if we have the following two lists:
	*
	* old: ABCD
	* new: CBDE
	*
	* It will iterate as follows
	* oldIndex = 0, newIndex = 0
	* old item (A) is removed, so add delete(0) and oldIndex++
	* oldIndex = 1, newIndex = 0
	* new item (C) is further down the list than oldIndex currently is, so add move(2, 0) and newIndex++
	* oldIndex = 1, newIndex = 1
	* Both indices are currently pointing at the same item (B), so oldIndex++ and newIndex++
	* oldIndex = 2, newIndex = 2
	* old item (C) has been moved up (and we know the move operation has already been generated because we only every move up), so oldIndex++
	* oldIndex = 3, newIndex = 2
	* Both indices are currently pointing at the same item (D), so oldIndex++ and newIndex++
	* oldIndex = 4, newIndex = 3
	* new item (E) is not in the old list, so add insert(3) and newIndex++
	* Both lists are exhausted, final operations are delete(0), move(2, 0) and insert(3)
	*
	* Whenever a section was also in the previous list, we compare the sections and perform the exact same algorithm on the individual rows.
	*/
	private func calculateChanges() {
		let newSections = Set(new.map { $0.key })
		var oldSections: [String: Int] = Dictionary(minimumCapacity: old.count)
		for (oldSectionIndex, oldSection) in old.enumerated() {
			oldSections[oldSection.key] = oldSectionIndex
		}

		// Keeps track of the current indexes
		var oldSectionIndex = 0
		var newSectionIndex = 0

		// Shared between iterations to reduce allocations
		var newRows: Set<String> = Set()
		var oldRows: [String: Int] = [:]
		while oldSectionIndex < old.count || newSectionIndex < new.count {
			// Skip over all the deleted or moved sections
			while oldSectionIndex < old.count {
				if !newSections.contains(old[oldSectionIndex].key) {
					deletedSections.insert(oldSectionIndex)
					oldSectionIndex += 1
				} else if movedSections.contains(where: { $0.from == oldSectionIndex }) {
					oldSectionIndex += 1
				} else {
					break
				}
			}

			// Insert and move up sections
			while newSectionIndex < new.count {
				if oldSectionIndex < old.count && new[newSectionIndex].key == old[oldSectionIndex].key {
					// Skip over equal sections
					repeat {
						compareRows(newRows: &newRows, oldRows: &oldRows, oldSectionIndex: oldSectionIndex, newSectionIndex: newSectionIndex)
						oldSectionIndex += 1
						newSectionIndex += 1
					} while oldSectionIndex < old.count &&
						newSectionIndex < new.count &&
						new[newSectionIndex].key == old[oldSectionIndex].key
					// Break because there might be sections that need to be deleted
					break
				} else if let oldSectionIndexLocation = oldSections[new[newSectionIndex].key] {
					// Move up existing section
					assert(oldSectionIndexLocation > oldSectionIndex)
					movedSections.append(MovedSection(
						from: oldSectionIndexLocation,
						to: newSectionIndex))
					compareRows(newRows: &newRows, oldRows: &oldRows, oldSectionIndex: oldSectionIndexLocation, newSectionIndex: newSectionIndex)
					newSectionIndex += 1
				} else {
					insertedSections.insert(newSectionIndex)
					newSectionIndex += 1
				}
			}
		}
	}

	private func isRow(new: (section: TableSection, row: Int), equalTo old: (section: TableSection, row: Int)) -> Bool {
		let newRow = new.section[new.row]
		let oldRow = old.section[old.row]
		guard newRow.isEqual(oldRow) else {
			return false
		}
		return new.section.mergedStyle(for: new.row) == old.section.mergedStyle(for: old.row)
	}

	private func compareRows(newRows: inout Set<String>, oldRows: inout [String: Int], oldSectionIndex: Int, newSectionIndex: Int) {
		// Clear the set and dictionary, ensuring we keep the capacity to reduce allocations
		newRows.removeAll(keepingCapacity: true)
		oldRows.removeAll(keepingCapacity: true)

		let oldSection = old[oldSectionIndex]
		let newSection = new[newSectionIndex]
		for newRow in newSection {
			newRows.insert(newRow.key)
		}
		for (oldSectionIndex, oldRow) in oldSection.enumerated() {
			oldRows[oldRow.key] = oldSectionIndex
		}

		var oldRowIndex = 0
		var newRowIndex = 0
		while oldRowIndex < oldSection.rows.count || newRowIndex < newSection.rows.count {
			// Skip over deleted and moved rows
			while oldRowIndex < oldSection.rows.count {
				if !newRows.contains(oldSection[oldRowIndex].key) {
					deletedRows.append(IndexPath(row: oldRowIndex, section: oldSectionIndex))
					oldRowIndex += 1
				} else if movedRows.contains(where: { $0.from == IndexPath(row: oldRowIndex, section: oldSectionIndex) }) {
					oldRowIndex += 1
				} else {
					break
				}
			}

			// Insert and move up rows
			while newRowIndex < newSection.rows.count {
				if oldRowIndex < oldSection.rows.count &&
					newSection[newRowIndex].key == oldSection[oldRowIndex].key {
					// Skip over all the rows that are the same (as a tight loop here because it's the most common case)
					repeat {
						let newRow = newSection[newRowIndex]
						// Compare existing row
						if visibleIndexPaths.contains(IndexPath(row: oldRowIndex, section: oldSectionIndex)) && !isRow(new: (section: newSection, row: newRowIndex), equalTo: (section: oldSection, row: oldRowIndex)) {
							if type(of: newRow) == type(of: oldSection[oldRowIndex]) {
								updates.append(Update(
									index: IndexPath(row: newRowIndex, section: newSectionIndex),
									cellConfig: newRow
								))
							} else {
								reloadedRows.append(IndexPath(row: newRowIndex, section: newSectionIndex))
							}
						}
						oldRowIndex += 1
						newRowIndex += 1
					} while oldRowIndex < oldSection.rows.count &&
						newRowIndex < newSection.rows.count &&
						newSection[newRowIndex].key == oldSection[oldRowIndex].key
					// Break because there might be rows that need to be deleted
					break
				} else if let oldRowIndexLocation = oldRows[newSection[newRowIndex].key] {
					let newRow = newSection[newRowIndex]
					// Move up existing row
					assert(oldRowIndexLocation > oldRowIndex)
					movedRows.append(MovedRow(
						from: IndexPath(row: oldRowIndexLocation, section: oldSectionIndex),
						to: IndexPath(row: newRowIndex, section: newSectionIndex)))
					if visibleIndexPaths.contains(IndexPath(row: oldRowIndexLocation, section: oldSectionIndex)) && !isRow(new: (section: newSection, row: newRowIndex), equalTo: (section: oldSection, row: oldRowIndexLocation)) {
						if type(of: newRow) == type(of: oldSection[oldRowIndex]) {
							updates.append(Update(
								index: IndexPath(row: newRowIndex, section: newSectionIndex),
								cellConfig: newRow
							))
						} else {
							reloadedRows.append(IndexPath(row: newRowIndex, section: newSectionIndex))
						}
					}
					newRowIndex += 1
				} else {
					// Insert new row
					insertedRows.append(IndexPath(row: newRowIndex, section: newSectionIndex))
					newRowIndex += 1
				}
			}
		}
	}

	public func jsonDebugInfo() -> [String: Any] {
		var debugSections: [[String: Any]] = []
		for index in insertedSections {
			debugSections.append([
				"operation": "insert",
				"index": index,
				])
		}
		for index in deletedSections {
			debugSections.append([
				"operation": "deleted",
				"index": index,
				])
		}
		for index in reloadedSections {
			debugSections.append([
				"operation": "update",
				"index": index,
				])
		}
		for move in movedSections {
			debugSections.append([
				"operation": "move",
				"from": move.from,
				"to": move.to,
				])
		}

		func stringFromIndexPath(_ indexPath: IndexPath) -> String {
			return "\(indexPath.section),\(indexPath.row)"
		}
		var debugRows: [[String: Any]] = []
		for indexPath in insertedRows {
			debugRows.append([
				"operation": "insert",
				"indexPath": stringFromIndexPath(indexPath),
				])
		}
		for indexPath in deletedRows {
			debugRows.append([
				"operation": "deleted",
				"indexPath": stringFromIndexPath(indexPath),
				])
		}
		for indexPath in reloadedRows {
			debugRows.append([
				"operation": "update",
				"indexPath": stringFromIndexPath(indexPath),
				])
		}
		for move in movedRows {
			debugRows.append([
				"operation": "move",
				"from": stringFromIndexPath(move.from),
				"to": stringFromIndexPath(move.to),
				])
		}

		return [
			"sections": debugSections,
			"rows": debugRows,
		]
	}
}
