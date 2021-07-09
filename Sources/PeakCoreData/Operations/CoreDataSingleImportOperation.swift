//
//  CoreDataSingleImportOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 25/09/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataSingleImportOperation<Intermediate: ManagedObjectUpdatable>: CoreDataChangesetOperation, ConsumesResult {
    
    typealias ManagedObject = Intermediate.ManagedObject
    
    public var input: Result<Intermediate, Error> = .failure(ResultError.noResult)
    
    open override func performWork(in context: NSManagedObjectContext) {
        do {
            let intermediate = try input.get()
            let managedObject = ManagedObject.fetchOrInsert(with: intermediate.uniqueIDValue, context: context, cache: cache)
            Intermediate.updateProperties?(intermediate, managedObject)
            Intermediate.updateRelationships?(intermediate, managedObject, context, cache)
            saveAndFinish()
        } catch {
            output = .failure(error)
            finish()
        }
    }
}
