//
//  PersistentStoreDescription.swift
//  THRCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData

/// A description object used to create and/or load a persistent store.
public struct PersistentStoreDescription {
    
    /// The URL that the store will use for its location.
    public let url: URL?
    
    /// The type of store this description represents.
    public var type: StoreType = .sqlite
    
    /**
     A flag that determines whether the store is added asynchronously.
     
     - discussion: By default, the store is added to the `PersistentStoreCoordinator` synchronously on the calling thread. 
     If this flag is set to true, the store is added asynchronously on a background queue. The default for this flag is false.
    */
    public var shouldAddStoreAsynchronously = false
    
    /**
     A flag indicating whether the associated persistent store should be migrated automatically.
     
     - discussion: This flag is set to true by default.
     */
    public var shouldMigrateStoreAutomatically = true
    
    internal var options: PersistentStoreOptions {
        guard shouldMigrateStoreAutomatically else { return [:] }
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
