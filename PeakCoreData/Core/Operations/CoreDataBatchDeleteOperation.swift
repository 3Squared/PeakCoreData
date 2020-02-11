//
//  CoreDataBatchDeleteOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 04/02/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataBatchDeleteEntityOperation<Entity: ManagedObjectType>: CoreDataOperation, ProducesResult {
    
    public var output: Result<Changeset, Error> = Result { throw ResultError.noResult }
    
    private let predicate: NSPredicate?
    
    public init(predicate: NSPredicate? = nil, persistentContainer: NSPersistentContainer, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.predicate = predicate
        super.init(persistentContainer: persistentContainer, mergePolicyType: mergePolicyType)
    }
    
    open override func performWork(in context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.entityName)
        request.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(deleteRequest) as! NSBatchDeleteResult
            let objectIDs = result.result as! [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            let changeset = Changeset(inserted: [], updated: [], deleted: Set(objectIDs))
            try saveOperationContext()
            output = .success(changeset)
        } catch {
            output = .failure(error)
        }
        finish()
    }
}
