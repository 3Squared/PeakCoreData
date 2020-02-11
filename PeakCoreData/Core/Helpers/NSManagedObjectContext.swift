//
//  NSManagedObjectContext.swift
//  PeakCoreData
//
//  Created by David Yates on 28/03/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    typealias VoidBlock = () -> Void
    typealias VoidBlockBlock = (VoidBlock) -> Void
    
    /// Helper function for convincing the type checker that
    /// the rethrows invariant holds for performAndWait.
    ///
    /// - Source: https://github.com/apple/swift/blob/bb157a070ec6534e4b534456d208b03adc07704b/stdlib/public/SDK/Dispatch/Queue.swift#L228-L249
    /// - Source: https://oleb.net/blog/2018/02/performandwait/
    @discardableResult
    public func performAndWait<T>(_ block: () throws -> T) rethrows -> T {
        
        func _helper<T>(fn: VoidBlockBlock, execute work: () throws -> T, rescue: ((Error) throws -> (T))) rethrows -> T {
            var r: T?
            var e: Error?
            withoutActuallyEscaping(work) { _work in
                fn {
                    do {
                        r = try _work()
                    } catch {
                        e = error
                    }
                }
            }
            if let error = e {
                return try rescue(error)
            }
            guard let result = r else {
                fatalError("Failed to generate a result or throw error.")
            }
            return result
        }
        
        return try _helper(fn: performAndWait(_:), execute: block, rescue: { throw $0 } )
    }
    
    /**
     Batch deletes all objects for all entities in the data model. An optional array of
     `NSManagedObjectContext` can be provided into which the deletions can be merged using the
     `mergeChanges(fromRemoteContextSave:into:)` function.
     
     - This method cannot be unit tested because it is incompatible with `NSInMemoryStoreType`.
     - This is a convenience function for calling `batchDelete(in:matching:)` on `NSEntityDescription`
     across all entities in the data model.
     
     - parameter context:       The context to use.
     - parameter mergeContexts: Optional contexts into which changes can be merged.
     */
    public func batchDeleteAllEntities(mergingInto mergeContexts: [NSManagedObjectContext]? = nil) {
        if let entities = persistentStoreCoordinator?.managedObjectModel.entities {
            for entity in entities {
                entity.batchDelete(in: self, mergingInto: mergeContexts)
            }
        }
    }
}

extension NSManagedObjectContext {
    
    public var deletedObjectIDs: Set<NSManagedObjectID> { Set(deletedObjects.map { $0.objectID }) }
    public var updatedObbjectIDs: Set<NSManagedObjectID> { Set(updatedObjects.map { $0.objectID }) }
    public var insertedObjectIDs: Set<NSManagedObjectID> { Set(insertedObjects.map { $0.objectID }) }
    
    public func calculateChangeset(with existingChangeset: Changeset? = nil) throws -> Changeset {
        guard hasChanges else { return existingChangeset ?? Changeset.empty }
        
        try obtainPermanentIDs(for: Array(insertedObjects))
        
        let existingDeleted: Set<NSManagedObjectID> = existingChangeset?.deleted ?? []
        let existingUpdated: Set<NSManagedObjectID> = existingChangeset?.updated ?? []
        let existingInserted: Set<NSManagedObjectID> = existingChangeset?.inserted ?? []
        
        let deleted = existingDeleted.union(deletedObjectIDs)
        let inserted = existingInserted.union(insertedObjectIDs).subtracting(deleted)
        let updated = existingUpdated.union(updatedObbjectIDs).subtracting(deleted)
        
        return Changeset(inserted: inserted, updated: updated, deleted: deleted)
    }
}
