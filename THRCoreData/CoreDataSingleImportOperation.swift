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

open class CoreDataSingleImportOperation<Intermediate>: CoreDataChangesetOperation, ConsumesResult where
    Intermediate: ManagedObjectUpdatable & UniqueIdentifiable,
    Intermediate.ManagedObject: ManagedObjectType & UniqueIdentifiable
{
    public var input: Result<Intermediate> = Result { throw ResultError.noResult }
    
    typealias ManagedObject = Intermediate.ManagedObject

    open override func performWork(in context: NSManagedObjectContext) {
        do {
            let intermediate = try input.resolve()
            let managedObject = ManagedObject.fetchOrInsertObject(with: intermediate.uniqueIDValue, in: context)
            intermediate.updateProperties(on: managedObject)
            intermediate.updateRelationships(on: managedObject, in: context)
            saveAndFinish()
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}
