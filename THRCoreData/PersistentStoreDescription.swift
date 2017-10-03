//
//  PersistentStoreDescription.swift
//  THRCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData

public typealias PersistentStoreOptions = [AnyHashable: Any]

fileprivate var migrateStoreOptions: PersistentStoreOptions {
    return [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
}

public enum StoreType {
    case sqlite
    case inMemory
    
    public var value: String {
        switch self {
        case .sqlite:
            return NSSQLiteStoreType
        case .inMemory:
            return NSInMemoryStoreType
        }
    }
}

/// A description object used to create and/or load a persistent store.
public class PersistentStoreDescription {
    
    /// The URL that the store will use for its location.
    public let url: URL?
    
    /// The type of store this description represents.
    public var type: StoreType = .sqlite
    
    /**
     A flag indicating whether the associated persistent store should be migrated automatically.
     
     - discussion: This flag is set to true by default.
     */
    public var shouldMigrateStoreAutomatically = true
    
    internal var options: PersistentStoreOptions? {
        guard shouldMigrateStoreAutomatically else { return nil }
        return migrateStoreOptions
    }

    /**
     Initializes the receiver with a URL for the store.
     
     - parameter url: Location for the store.
     
     - return: Initialized PersistentStoreDescription configured with the given URL.
    */
    public init(url: URL) {
        self.url = url
    }
}