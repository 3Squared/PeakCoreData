//
//  ImportManyOperation.swift
//  PeakCoreData
//
//  Created by Ben Walker on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataBatchImportOperation<Intermediate>: CoreDataChangesetOperation, ConsumesResult where
    Intermediate: ManagedObjectUpdatable & UniqueIdentifiable,
    Intermediate.ManagedObject: ManagedObjectType & UniqueIdentifiable
{
    public var input: Result<[Intermediate], Error> = Result { throw ResultError.noResult }
    
    typealias ManagedObject = Intermediate.ManagedObject
    
    open override func performWork(in context: NSManagedObjectContext) {
        do {
            let intermediates = try input.get()
            
            let importProgress = Progress(totalUnitCount: Int64(intermediates.count) * 2)
            progress.addChild(importProgress, withPendingUnitCount: progress.totalUnitCount)

            ManagedObject.insertOrUpdate(intermediates: intermediates, in: context, with: cache) { intermediate, managedObject in
                intermediate.updateProperties(on: managedObject)
                importProgress.completedUnitCount += 1
            }
            
            ManagedObject.insertOrUpdate(intermediates: intermediates, in: context, with: cache) { intermediate, managedObject in
                intermediate.updateRelationships(on: managedObject, in: context)
                importProgress.completedUnitCount += 1
            }
            
            saveAndFinish()
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}
