//
//  NSManagedObjectContext.swift
//  PeakCoreData
//
//  Created by David Yates on 28/03/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    /**
     Batch deletes all objects for all entities in the data model. An optional array of
     `NSManagedObjectContext` can be provided into which the deletions can be merged using the
     `mergeChanges(fromRemoteContextSave:into:)` function.
     
     - This method cannot be unit tested because it is incompatible with `NSInMemoryStoreType`.
     - This is a convenience function for calling `batchDelete(in:matching:)` on `NSEntityDescription`
     across all entities in the data model.
     
     - parameter context:       The context to use.
     - parameter mergeContexts: Optional contexts into which changes can be merged.
     */
    public func batchDeleteAllEntities(mergingInto mergeContexts: [NSManagedObjectContext]? = nil) {
        if let entities = persistentStoreCoordinator?.managedObjectModel.entities {
            for entity in entities {
                entity.batchDelete(in: self, mergingInto: mergeContexts)
            }
        }
    }
}
