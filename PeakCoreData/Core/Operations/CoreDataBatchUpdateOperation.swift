//
//  CoreDataBatchUpdateOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 21/05/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import CoreData

/// Performs an `NSBatchUpdateRequest` and returns an array of updated `NSManagedObjectID`s.
class CoreDataBatchUpdateOperation<Entity: ManagedObjectType>: CoreDataOperation<[NSManagedObjectID]> {
        
    private let propertiesToUpdate: [AnyHashable: Any]
    private let predicate: NSPredicate?
    private let mergeContexts: [NSManagedObjectContext]?
    
    init(propertiesToUpdate: [AnyHashable: Any], predicate: NSPredicate? = nil, mergeContexts: [NSManagedObjectContext]? = nil, persistentContainer: NSPersistentContainer, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.propertiesToUpdate = propertiesToUpdate
        self.predicate = predicate
        self.mergeContexts = mergeContexts
        super.init(persistentContainer: persistentContainer, mergePolicyType: mergePolicyType)
    }
    
    override func performWork(in context: NSManagedObjectContext) {
        let request = NSBatchUpdateRequest(entityName: Entity.entityName)
        request.predicate = predicate
        request.propertiesToUpdate = propertiesToUpdate
        request.resultType = .updatedObjectIDsResultType
        do {
            let result = try context.execute(request) as! NSBatchUpdateResult
            let objectIDArray = result.result as! [NSManagedObjectID]
            if let mergeContexts = mergeContexts, !mergeContexts.isEmpty {
                let changes = [NSUpdatedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: mergeContexts)
            }
            output = .success(objectIDArray)
        } catch {
            output = .failure(error)
        }
        finish()
    }
}
