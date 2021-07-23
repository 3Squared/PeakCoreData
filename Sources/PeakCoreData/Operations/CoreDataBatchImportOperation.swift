//
//  CoreDataBatchImportOperation.swift
//  PeakCoreData
//
//  Created by Ben Walker on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataBatchImportOperation<Intermediate: ManagedObjectUpdatable>: CoreDataChangesetOperation, ConsumesResult {
    
    typealias ManagedObject = Intermediate.ManagedObject
    
    public var input: Result<[Intermediate], Error> = .failure(ResultError.noResult)
    
    open override func performWork(in context: NSManagedObjectContext) {
        do {
            let intermediates = try input.get()
            
            let count = intermediates.count * ((Intermediate.hasProperties && Intermediate.hasRelationships) ? 2 : 1)
            let importProgress = Progress(totalUnitCount: Int64(count))
            progress.addChild(importProgress, withPendingUnitCount: progress.totalUnitCount)
            
            if let updateProperties = Intermediate.updateProperties {
                ManagedObject.insertOrUpdate(intermediates: intermediates, context: context, cache: cache) { intermediate, managedObject in
                    updateProperties(intermediate, managedObject)
                    importProgress.completedUnitCount += 1
                }
            }
            
            if let updateRelationships = Intermediate.updateRelationships {
                ManagedObject.insertOrUpdate(intermediates: intermediates, context: context, cache: cache) { intermediate, managedObject in
                    updateRelationships(intermediate, managedObject, context, self.cache)
                    importProgress.completedUnitCount += 1
                }
            }
            
            saveAndFinish()
        } catch {
            output = .failure(error)
            finish()
        }
    }
}
