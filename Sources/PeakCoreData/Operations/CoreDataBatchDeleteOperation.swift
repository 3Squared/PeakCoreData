//
//  CoreDataBatchDeleteOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 21/05/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import CoreData

/// Performs an `NSBatchDeleteRequest` and returns an array of deleted `NSManagedObjectID`s.
open class CoreDataBatchDeleteOperation<Entity: ManagedObjectType>: CoreDataOperation<[NSManagedObjectID]> {
    
    private let predicate: NSPredicate?
    private let mergeContexts: [NSManagedObjectContext]?

    public init(predicate: NSPredicate? = nil, mergeContexts: [NSManagedObjectContext]? = nil, persistentContainer: NSPersistentContainer, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.predicate = predicate
        self.mergeContexts = mergeContexts
        super.init(persistentContainer: persistentContainer, mergePolicyType: mergePolicyType)
    }
    
    open override func performWork(in context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.entityName)
        request.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(deleteRequest) as! NSBatchDeleteResult
            let objectIDArray = result.result as! [NSManagedObjectID]
            if let mergeContexts = mergeContexts, !mergeContexts.isEmpty {
                let changes = [NSDeletedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: mergeContexts)
            }
            output = .success(objectIDArray)
        } catch {
            output = .failure(error)
        }
        finish()
    }
}
