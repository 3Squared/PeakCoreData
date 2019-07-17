//
//  CoreDataBatchDeleteAllEntitiesOperation.swift
//  PeakCoreData
//
//  Created by Ben Walker on 17/07/2019.
//

import CoreData
import PeakOperation

open class CoreDataBatchDeleteAllEntitiesOperation: CoreDataOperation<Void> {
    
    open override func performWork(in context: NSManagedObjectContext) {
        context.batchDeleteAllEntities()
        saveAndFinish()
    }
}
