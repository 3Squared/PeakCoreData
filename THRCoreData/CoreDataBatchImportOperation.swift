//
//  ImportManyOperation.swift
//  THRCoreData
//
//  Created by Ben Walker on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import THROperations
import THRResult

open class CoreDataBatchImportOperation<Intermediate>: CoreDataOperation<Changeset>, ConsumesResult where
    Intermediate: ManagedObjectUpdatable,
    Intermediate: UniqueIdentifiable,
    Intermediate.ManagedObject: ManagedObjectType,
    Intermediate.ManagedObject: UniqueIdentifiable
{
    public var input: Result<[Intermediate]> = Result { throw ResultError.noResult }
    
    typealias ManagedObject = Intermediate.ManagedObject

    open override func performWork(in context: NSManagedObjectContext) {
        do {
            let intermediates = try input.resolve()
            
            ManagedObject.insertOrUpdate(intermediates: intermediates, in: context) { intermediate, managedObject in
                intermediate.updateProperties(on: managedObject)
            }
            
            ManagedObject.insertOrUpdate(intermediates: intermediates, in: context) { intermediate, managedObject in
                intermediate.updateRelationships(on: managedObject, in: context)
            }
            
            saveOperationContext()

            output = Result {
                let allIds = inserted.union(updated)
                
                return Changeset(all: allIds,
                                 inserted: inserted,
                                 updated: updated)
            }
            
            finish()
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}
