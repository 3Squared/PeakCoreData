//
//  CoreDataBatchUpdateOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 04/02/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

class CoreDataBatchUpdateEntityOperation<Entity: ManagedObjectType>: CoreDataOperation, ProducesResult {
    
    var output: Result<Changeset, Error> = Result { throw ResultError.noResult }
    
    private let predicate: NSPredicate?
    private let propertiesToUpdate: [AnyHashable: Any]
    
    init(propertiesToUpdate: [AnyHashable: Any], predicate: NSPredicate? = nil, persistentContainer: NSPersistentContainer, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.predicate = predicate
        self.propertiesToUpdate = propertiesToUpdate
        super.init(persistentContainer: persistentContainer, mergePolicyType: mergePolicyType)
    }
    
    override func performWork(in context: NSManagedObjectContext) {
        let request = NSBatchUpdateRequest(entityName: Entity.entityName)
        request.predicate = predicate
        request.propertiesToUpdate = propertiesToUpdate
        request.resultType = .updatedObjectIDsResultType
        do {
            let result = try context.execute(request) as! NSBatchUpdateResult
            let objectIDs = result.result as! [NSManagedObjectID]
            let changes = [NSUpdatedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            let changeset = Changeset(inserted: [], updated: Set(objectIDs), deleted: [])
            try saveOperationContext()
            output = .success(changeset)
        } catch {
            output = .failure(error)
        }
        finish()
    }
}
