//
//  CoreDataStackSettable.swift
//  PeakCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

public protocol PersistentContainerSettable: class {
    var persistentContainer: NSPersistentContainer! { get set }
}

public extension PersistentContainerSettable {
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveViewContext() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving view context: \(error)")
        }
    }
}

public protocol HasContext: AnyObject {
    var context: NSManagedObjectContext? { get }
    func willSave(context: NSManagedObjectContext)
    func didSave(context: NSManagedObjectContext, saveError: Error?)
    func saveContext() throws
}

public extension HasContext {
    
    var deletedObjectIDs: Set<NSManagedObjectID> {
        let deletedObjects = context?.deletedObjects ?? []
        return Set(deletedObjects.map { $0.objectID })
    }
    
    var updatedObbjectIDs: Set<NSManagedObjectID> {
        let updatedObjects = context?.updatedObjects ?? []
        return Set(updatedObjects.map { $0.objectID })
    }
    
    var insertedObjectIDs: Set<NSManagedObjectID> {
        let insertedObjects = context?.insertedObjects ?? []
        return Set(insertedObjects.map { $0.objectID })
    }
    
    func willSave(context: NSManagedObjectContext) {}
    func didSave(context: NSManagedObjectContext, saveError: Error?) {}
    
    func calculateChangeset(with existingChangeset: Changeset? = nil) throws -> Changeset {
        guard let context = context, context.hasChanges else { return Changeset.emptyChangeset }
        
        try context.obtainPermanentIDs(for: Array(context.insertedObjects))
        
        let existingDeleted: Set<NSManagedObjectID> = existingChangeset?.deleted ?? []
        let existingUpdated: Set<NSManagedObjectID> = existingChangeset?.updated ?? []
        let existingInserted: Set<NSManagedObjectID> = existingChangeset?.inserted ?? []
        
        let deleted = existingDeleted.union(deletedObjectIDs)
        let inserted = existingInserted.union(insertedObjectIDs).subtracting(deleted)
        let updated = existingUpdated.union(updatedObbjectIDs).subtracting(deleted)
        
        return Changeset(inserted: inserted, updated: updated, deleted: deleted)
    }
    
    func saveContext() throws {
        guard let context = context, context.hasChanges else { return }
        
        willSave(context: context)
        
        do {
            try context.save()
            didSave(context: context, saveError: nil)
        } catch {
            didSave(context: context, saveError: error)
            throw error
        }
    }
}

public extension HasContext where Self: ProducesResult, Self.Output == Changeset {
    
    func saveContext() throws {
        guard let context = context, context.hasChanges else {
            output = .success(Changeset.emptyChangeset)
            return
        }
        
        do {
            let changeset = try calculateChangeset()
            try context.save()
            output = .success(changeset)
            didSave(context: context, saveError: nil)
        } catch {
            output = .failure(error)
            didSave(context: context, saveError: error)
        }
    }
}
