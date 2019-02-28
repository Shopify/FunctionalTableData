//
//  KeyPathType.swift
//  FunctionalTableData
//
//  Created by Alex Liu on 2019-02-26.
//  Copyright © 2019 Shopify. All rights reserved.
//

import Foundation

/// Represents the unique path to a given item in the `FunctionalCollectionData` or `FunctionalTableData`.
///
/// Think of it as a readable implementation of `IndexPath`, that can be used to locate a given cell
/// or `TableSection` in the data set.
public struct KeyPath: Equatable {
    /// Unique identifier for a section.
    public let sectionKey: String
    /// Unique identifier for an item inside a section.
    public let rowKey: String
    
    public init(sectionKey: String, rowKey: String) {
        self.sectionKey = sectionKey
        self.rowKey = rowKey
    }
    
    public static func ==(lhs: KeyPath, rhs: KeyPath) -> Bool {
        return lhs.sectionKey == rhs.sectionKey && lhs.rowKey == rhs.rowKey
    }
}

public protocol KeyPathType {
    var tableSections: [TableSection] { get }
    
    /// Returns the IndexPath of the item at the specified point, or `nil` if no item was found at that point.
    ///
    /// - Parameter point: The point in the collection/table view’s bounds that you want to test.
    /// - Returns: The keypath of the item at the specified point, or `nil` if no item was found at that point.
    func indexPathForRow(at point: CGPoint) -> IndexPath?
    func keyRowForIndexPath(at indexPath: IndexPath, in section: TableSection) -> CellConfigType
    func keyIndexPath(at row: Int, in section: Int) -> IndexPath
    
    /// Returns the cell identified by a key path.
    ///
    /// - Parameter keyPath: A key path identifying the cell to look up.
    /// - Returns: A `CellConfigType` instance corresponding to the key path or `nil` if the key path is invalid.
    func rowForKeyPath(_ keyPath: KeyPath) -> CellConfigType?
    
    /// Returns the key path specified by its string presentation.
    ///
    /// - Parameter key: String identifier to lookup.
    /// - Returns: A `KeyPath` that matches the key or `nil` if there is no match.
    func keyPathForRowKey(_ key: String) -> KeyPath?
    
    /// Returns the key path of the cell in a given `IndexPath` location.
    ///
    /// __Note:__ This method performs an unsafe lookup, make sure that the `IndexPath` exists
    /// before trying to transform it into a `KeyPath`.
    /// - Parameter indexPath: A key path identifying where the key path is located.
    /// - Returns: The key representation of the supplied `IndexPath`.
    func keyPathForIndexPath(indexPath: IndexPath) -> KeyPath
    
    /// - Parameter point: The point in the collection/table view’s bounds that you want to test.
    /// - Returns: The keypath of the item at the specified point, or `nil` if no item was found at that point.
    func keyPath(at point: CGPoint) -> KeyPath?
    
    /// Returns the IndexPath corresponding to the provided KeyPath.
    ///
    /// - Parameter keyPath: The path representing the desired indexPath.
    /// - Returns: The IndexPath of the item at the provided keyPath.
    func indexPathFromKeyPath(_ keyPath: KeyPath) -> IndexPath?
}

extension KeyPathType
{
    /// Returns the cell identified by a key path.
    ///
    /// - Parameter keyPath: A key path identifying the cell to look up.
    /// - Returns: A `CellConfigType` instance corresponding to the key path or `nil` if the key path is invalid.
    public func rowForKeyPath(_ keyPath: KeyPath) -> CellConfigType? {
        if let sectionIndex = tableSections.index(where: { $0.key == keyPath.sectionKey }), let rowIndex = tableSections[sectionIndex].rows.index(where: { $0.key == keyPath.rowKey }) {
            return tableSections[sectionIndex].rows[rowIndex]
        }
        
        return nil
    }
    
    /// Returns the key path specified by its string presentation.
    ///
    /// - Parameter key: String identifier to lookup.
    /// - Returns: A `KeyPath` that matches the key or `nil` if there is no match.
    public func keyPathForRowKey(_ key: String) -> KeyPath? {
        for section in tableSections {
            for row in section {
                if row.key == key {
                    return KeyPath(sectionKey: section.key, rowKey: row.key)
                }
            }
        }
        
        return nil
    }
    
    /// Returns the key path of the cell in a given `IndexPath` location.
    ///
    /// __Note:__ This method performs an unsafe lookup, make sure that the `IndexPath` exists
    /// before trying to transform it into a `KeyPath`.
    /// - Parameter indexPath: A key path identifying where the key path is located.
    /// - Returns: The key representation of the supplied `IndexPath`.
    public func keyPathForIndexPath(indexPath: IndexPath) -> KeyPath {
        let section = tableSections[indexPath.section]
        let row = keyRowForIndexPath(at: indexPath, in: section)
        return KeyPath(sectionKey: section.key, rowKey: row.key)
    }
    
    /// - Parameter point: The point in the collection/table view’s bounds that you want to test.
    /// - Returns: the keypath of the item at the specified point, or `nil` if no item was found at that point.
    public func keyPath(at point: CGPoint) -> KeyPath? {
        guard let indexPath = indexPathForRow(at: point) else {
            return nil
        }
        
        return keyPathForIndexPath(indexPath: indexPath)
    }
    
    public func indexPathFromKeyPath(_ keyPath: KeyPath) -> IndexPath? {
        if let sectionIndex = tableSections.index(where: { $0.key == keyPath.sectionKey }), let rowIndex = tableSections[sectionIndex].rows.index(where: { $0.key == keyPath.rowKey }) {
            return keyIndexPath(at: rowIndex, in: sectionIndex)
        }
        
        return nil
    }
}
