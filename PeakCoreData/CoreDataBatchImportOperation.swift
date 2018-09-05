//
//  ImportManyOperation.swift
//  PeakCoreData
//
//  Created by Ben Walker on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import PeakOperation
import PeakResult

open class CoreDataBatchImportOperation<Intermediate>: CoreDataChangesetOperation, ConsumesResult where
    Intermediate: ManagedObjectUpdatable & UniqueIdentifiable,
    Intermediate.ManagedObject: ManagedObjectType & UniqueIdentifiable
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
            
            saveAndFinish()
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}
