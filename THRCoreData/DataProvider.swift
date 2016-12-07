//
//  DataProvider.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData

public protocol DataProvider: class {
    
    associatedtype Object: NSManagedObject
    
    var numberOfSections: Int { get }
    var allObjects: [Object]? { get }
    var sectionNameKeyPath: String? { get }
    var isEmpty: Bool { get }
    var sectionIndexTitles: [String] { get }

    func numberOfItems(in section: Int) -> Int
    func name(in section: Int) -> String?
    func object(at indexPath: IndexPath) -> Object
    func section(forSectionIndexTitle title: String, at index: Int) -> Int
    func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo
}

public protocol DataProviderDelegate: class {
    
    associatedtype Object: NSManagedObject
    
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Object>]?)
}

public enum DataProviderUpdate<Object> {
    
    case insert(at: IndexPath)
    case update(at: IndexPath, with: Object)
    case move(from: IndexPath, to: IndexPath)
    case delete(at: IndexPath)
    case insertSection(at: Int)
    case deleteSection(at: Int)
}

