//
//  PersistentStoreDescription.swift
//  THRCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData

public struct PersistentStoreDescription {
    
    public let url: URL?
    public var type: StoreType = .sqlite
    public var options = defaultStoreOptions
    public var shouldAddStoreAsynchronously = false

    public init(url: URL) {
        self.url = url
    }
}
