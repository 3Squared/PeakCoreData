//
//  ChangeSet.swift
//  PeakCoreData
//
//  Created by David Yates on 25/09/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData

/// A struct containing the NSManagedObjectIDs of the objects affected by the import.
//  all: all objects touched by the operation
//  inserted: newly created objects
//  updated: objects that existed before the import that may have been modified
public struct Changeset {
    public let inserted: Set<NSManagedObjectID>
    public let updated: Set<NSManagedObjectID>
    public var all: Set<NSManagedObjectID> {
        inserted.union(updated)
    }
}
