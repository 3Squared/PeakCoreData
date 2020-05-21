//
//  CoreDataImportObjectOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 25/09/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataSingleImportOperation<Intermediate>: CoreDataChangesetOperation, ConsumesResult where
    Intermediate: ManagedObjectUpdatable & UniqueIdentifiable,
    Intermediate.ManagedObject: ManagedObjectType & UniqueIdentifiable
{
    public var input: Result<Intermediate, Error> = Result { throw ResultError.noResult }
    
    typealias ManagedObject = Intermediate.ManagedObject

    open override func performWork(in context: NSManagedObjectContext) {
        do {
            let intermediate = try input.get()
            let managedObject = ManagedObject.fetchOrInsertObject(with: intermediate.uniqueIDValue, in: context, with: cache)
            intermediate.updateProperties(on: managedObject)
            intermediate.updateRelationships(on: managedObject, in: context)
            saveAndFinish()
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}
