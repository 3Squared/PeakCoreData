//
//  ManagedObjectType.Swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

// Adapted from: https://www.objc.io/books/core-data/

import Foundation
import CoreData

public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

public extension ManagedObjectType {
    static var entityName: String { return String(describing: self) }
    static var defaultSortDescriptors: [NSSortDescriptor] { return [] }
}

public extension ManagedObjectType where Self: NSManagedObject {
    
    typealias FetchRequestConfigurationBlock = (NSFetchRequest<Self>) -> ()
    typealias ManagedObjectConfigurationBlock = (Self) -> ()
    
    /**
     - parameter context:       The context to use.
     - parameter configure:     Optional configuration block to be applied to the inserted object.
     
     - returns: An initialized and configured instance of the appropriate entity (discardable).
     */
    @discardableResult
    static func insertObject(in context: NSManagedObjectContext, configure: ManagedObjectConfigurationBlock? = nil) -> Self {
        let object = Self(context: context)
        configure?(object)
        return object
    }
    
    /**
     - parameter configure:     Optional configuration block for the fetch request.
     
     - returns: A configured fetch request for the entity, with `defaultSortDescriptors` applied.
     - note: A `fetchBatchSize` of 20 is applied to improve performance. This can be
     */
    static func sortedFetchRequest(configure: FetchRequestConfigurationBlock? = nil) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        fetchRequest.sortDescriptors = defaultSortDescriptors
        fetchRequest.fetchBatchSize = 20
        configure?(fetchRequest)
        return fetchRequest
    }
    
    /**
     - parameter context:       The context to use.
     - parameter configure:     Optional configuration block to be applied to the fetch request.
     
     - returns: An array of objects matching the configured fetch request, sorted by `defaultSortDescriptors`.
     */
    static func fetch(in context: NSManagedObjectContext, configure: FetchRequestConfigurationBlock? = nil) -> [Self] {
        let request = sortedFetchRequest(configure: configure)
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Error fetching \(entityName)s: \(error)")
        }
    }
    
    /**
     - parameter context:       The context to use.
     - parameter predicate:     Optional predicate to be applied to the count fetch request.
     
     - returns: The count of all objects or all objects matching the predicate.
     */
    static func count(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) -> Int {
        let countRequest = NSFetchRequest<Self>(entityName: entityName)
        countRequest.predicate = predicate
        do {
            return try context.count(for: countRequest)
        } catch {
            fatalError("Error counting \(entityName)s: \(error)")
        }
    }
    
    /**
     Deletes all objects or all objects matching a predicate.
     
     - parameter context:       The context to use.
     - parameter predicate:     Optional predicate to be applied to the fetch request.
     */
    static func delete(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) {
        let deleteRequest = NSFetchRequest<Self>(entityName: entityName)
        deleteRequest.predicate = predicate
        deleteRequest.includesPropertyValues = false
        do {
            let itemsToDelete = try context.fetch(deleteRequest)
            itemsToDelete.forEach { context.delete($0) }
        } catch {
            fatalError("Error fetching \(entityName)s: \(error)")
        }
    }
    
    /**
     Batch deletes all objects or all objects matching a predicate.
     
     - Note: This should be significantly faster than the `delete(in:matching)` method for large datasets.
     - Note: This method cannot be unit tested because it is incompatible with `NSInMemoryStoreType`.
     
     - parameter context:       The context to use.
     - parameter predicate:     Optional predicate to be applied to the fetch request.
     */
    static func batchDelete(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(deleteRequest) as! NSBatchDeleteResult
            let objectIDArray = result.result as! [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        } catch {
            fatalError("Failed to perform batch update: \(error)")
        }
    }
}

// MARK: - UniqueIdentifiable

public extension ManagedObjectType where Self: NSManagedObject & UniqueIdentifiable {
    
    typealias UniqueKeyValueType = Any
    
    /**
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - parameter uniqueKeyValue:    The unique id of the object you want to fetch.
     
     - returns: A predicate that can be used to fetch a single object with the specified unique id.
     */
    static func uniqueObjectPredicate(with uniqueKeyValue: UniqueKeyValueType) -> NSPredicate {
        return NSPredicate(format: "%K == %@", argumentArray: [Self.uniqueIDKey, uniqueKeyValue])
    }
    
    /**
     Inserts an object in to the context, applies the unique id and then configures the object (optional).
     
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - parameter uniqueKeyValue:    The unique id of the object you want to insert.
     - parameter context:           The context to use.
     - parameter configure:         Optional configuration block to be applied to the inserted object.
     
     - returns: An initialized and configured instance of the appropriate entity (discardable).
     */
    @discardableResult
    static func insertObject(with uniqueKeyValue: UniqueKeyValueType, in context: NSManagedObjectContext, configure: ManagedObjectConfigurationBlock? = nil) -> Self {
        return insertObject(in: context) { object in
            object.setValue(uniqueKeyValue, forKey: uniqueIDKey)
            configure?(object)
        }
    }
    
    /**
     Efficient method for fetching a single object by its unique id.
     
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - parameter uniqueKeyValue:    The unique id of the object you want to fetch.
     - parameter context:           The context to use.
     
     - returns: The object with the specified unique id.
     */
    static func fetchObject(with uniqueKeyValue: UniqueKeyValueType, in context: NSManagedObjectContext) -> Self? {
        let predicate = uniqueObjectPredicate(with: uniqueKeyValue)
        return fetch(in: context) { request in
            request.predicate = predicate
            request.fetchLimit = 1
            }.first
    }
    
    /**
     Fetches an object with the specified unique id if it exists, or inserts one if it doesn't.
     
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - parameter uniqueKeyValue:    The unique id of the object you want to fetch or insert.
     - parameter context:           The context to use.
     - parameter configure:         Configuration block, which can be used to configure the object once fetched or inserted.
     
     - returns: The object with the specified unique id.
     */
    @discardableResult
    static func fetchOrInsertObject(with uniqueKeyValue: UniqueKeyValueType, in context: NSManagedObjectContext, configure: ManagedObjectConfigurationBlock? = nil) -> Self {
        guard let existingObject = fetchObject(with: uniqueKeyValue, in: context) else {
            return insertObject(with: uniqueKeyValue, in: context, configure: configure)
        }
        configure?(existingObject)
        return existingObject
    }
    
    /**
     Efficient batch insert or update adapted from Apple's Core Data Programming Guide (no longer available).
     
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - Warning: This method can create duplicates in some circumstances. If you are inserting an object that has circular dependancies, such as a parent-child relationship,
     then many additional objects will be inserted as the method caches the objects that already exist when it begins. If additional objects of the same type as being inserted are added,
     then this method will not know about them, and insert duplicates. Please see the test `testBatchInsertCreatesDuplicatesInSomeSituations` for an example.
     
     - parameter intermediates:         An array of intermediate objects (e.g. structs) that conform to UniqueIdentifiable. These will be used to create or update the Managed Objects.
     - parameter context:               The context to use.
     - parameter configure:             A configuration block, called with the intermediate object and either:
     a) an existing managed object for you to update, or; 
     b) a newly inserted managed object for you to set the fields.
     In both cases the unique identifier will already be set
     */
    static func insertOrUpdate<IntermediateType: UniqueIdentifiable>(intermediates: [IntermediateType], in context: NSManagedObjectContext, configure: (IntermediateType, Self) -> ()) {
        
        // Nothing to insert, exit immediately.
        
        guard intermediates.count != 0 else { return }
        
        // Sort the array of intermediate representations by their ID value
        
        let sortedIntermediates = intermediates.sorted { first, second -> Bool in
            return first.uniqueIDValue < second.uniqueIDValue
        }
        
        // Also get an array containing only the IDs
        
        let sortedIntermediateIDs = sortedIntermediates.map { $0.uniqueIDValue }
        
        // Create a fetch request for all objects whose IDs are the same as the intermediate objects.
        // These are our existing object we want to update.
        
        let uniqueIDKey = Self.uniqueIDKey
        
        let request = sortedFetchRequest { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(%K IN %@)", argumentArray: [uniqueIDKey, sortedIntermediateIDs])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: uniqueIDKey, ascending: true)]
        }
        
        guard let matchingObjects = try? context.fetch(request) else { fatalError("Error fetching!") }
        
        // Create iterators to move through both sets of objects.
        // Both start at 0. We move through the remote objects.
        // When a matching managed object is found, we move on by one.
        
        var managedObjectIterator = matchingObjects.makeIterator()
        var intermediatesIterator = sortedIntermediates.makeIterator()
        
        var intermediate = intermediatesIterator.next()
        var managedObject = managedObjectIterator.next()
        
        while intermediate != nil {
            let intermediateID = intermediate!.uniqueIDValue
            if let existingObject = managedObject, existingObject.uniqueIDValue == intermediate!.uniqueIDValue {
                configure(intermediate!, existingObject)
                managedObject = managedObjectIterator.next()
            } else {
                let newObject = insertObject(with: intermediateID, in: context)
                configure(intermediate!, newObject)
            }
            intermediate = intermediatesIterator.next()
        }
    }
}
