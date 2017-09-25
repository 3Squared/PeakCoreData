//
//  CoreDataImportObjectOperation.swift
//  THRCoreData
//
//  Created by David Yates on 25/09/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData
import THROperations
import THRResult

class CoreDataImportObjectOperation<Intermediate>: CoreDataOperation<Changeset>, ConsumesResult where
    Intermediate: ManagedObjectUpdatable,
    Intermediate: UniqueIdentifiable,
    Intermediate.ManagedObject: ManagedObjectType,
    Intermediate.ManagedObject: UniqueIdentifiable
{
    public var input: Result<Intermediate> = Result { throw ResultError.noResult }
    
    typealias ManagedObject = Intermediate.ManagedObject

    override func performWork(inContext context: NSManagedObjectContext) {
        do {
            let intermediate = try input.resolve()
            let managedObject = ManagedObject.fetchOrInsertObject(withUniqueKeyValue: intermediate.uniqueIDValue, inContext: context)
            
            intermediate.updateProperties(on: managedObject)
            intermediate.updateRelationships(on: managedObject, withContext: context)
            
            try context.obtainPermanentIDs(for: Array(context.insertedObjects))
            
            output = Result {
                let insertedIds = Set(context.insertedObjects.map { $0.objectID })
                let updatedIds = Set(context.updatedObjects.map { $0.objectID })
                let allIds = insertedIds.union(updatedIds)
                
                return Changeset(all: allIds,
                                 inserted: insertedIds,
                                 updated: updatedIds)
            }
            finishAndSave()
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}
