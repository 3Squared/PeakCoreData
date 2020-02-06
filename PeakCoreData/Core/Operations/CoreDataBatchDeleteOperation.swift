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
    
    public var output: Result<Int, Error> = Result { throw ResultError.noResult }
    
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
            let objectIDArray = result.result as! [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            try saveOperationContext()
            output = .success(objectIDArray.count)
        } catch {
            output = .failure(error)
        }
        finish()
    }
}
