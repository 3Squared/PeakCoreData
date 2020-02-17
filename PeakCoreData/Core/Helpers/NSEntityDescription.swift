//
//  NSEntityDescription.swift
//  PeakCoreData
//
//  Created by Ben Walker on 15/07/2019.
//

import CoreData

extension NSEntityDescription {
    /**
     Batch deletes all objects or all objects matching a predicate. An optional array of
     `NSManagedObjectContext` can be provided into which the deletions can be merged using the
     `mergeChanges(fromRemoteContextSave:into:)` function.
     
     - This function cannot be unit tested because it is incompatible with `NSInMemoryStoreType`.
     
     - parameter context:       The context to use.
     - parameter predicate:     Optional predicate to be applied to the fetch request.
     - parameter mergeContexts: Optional contexts into which changes can be merged.
     */
    public func batchDelete(in context: NSManagedObjectContext,
                            matching predicate: NSPredicate? = nil,
                            mergingInto mergeContexts: [NSManagedObjectContext]? = nil) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.name!)
        request.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(deleteRequest) as! NSBatchDeleteResult
            
            if let contexts = mergeContexts {
                let objectIDArray = result.result as! [NSManagedObjectID]
                let changes = [NSDeletedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: contexts)
            }
        } catch {
            fatalError("Failed to perform batch update: \(error)")
        }
    }
}
