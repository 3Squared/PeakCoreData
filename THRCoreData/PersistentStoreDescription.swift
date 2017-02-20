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
    
    public let url: URL?
    public var type: StoreType = .sqlite
    public var options = defaultStoreOptions
    /**
     A flag that determines whether the store is added asynchronously.
     
     - discussion: By default, the store is added to the `PersistentStoreCoordinator` synchronously on the calling thread. 
     If this flag is set to true, the store is added asynchronously on a background queue. The default for this flag is false.
    */
    public var shouldAddStoreAsynchronously = false

    /**
     Initializes the receiver with a URL for the store.
     
     - parameter url: Location for the store.
     
     - return: Initialized PersistentStoreDescription configured with the given URL.
    */
    public init(url: URL) {
        self.url = url
    }
}
