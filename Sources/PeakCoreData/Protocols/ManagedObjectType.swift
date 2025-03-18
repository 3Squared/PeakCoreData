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

public protocol ManagedObjectType: NSManagedObject {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

public extension ManagedObjectType {
    
    typealias FetchRequestConfigurationBlock = (NSFetchRequest<Self>) -> Void
    typealias ManagedObjectConfigurationBlock = (Self) -> Void
    
    static var entityName: String { String(describing: self) }
    static var defaultSortDescriptors: [NSSortDescriptor] { [] }
    
    /**
     - parameter context:       The context to use.
     - parameter configure:     Optional configuration block to be applied to the inserted object.
     
     - returns: An initialized and configured instance of the appropriate entity (discardable).
     */
    @discardableResult
    static func insertObject(in context: NSManagedObjectContext, configure: ManagedObjectConfigurationBlock? = nil) -> Self {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? Self else { fatalError("Wrong object type inserted.")}
        configure?(object)
        return object
    }
    
    /**
     - parameter configure:     Optional configuration block for the fetch request.
     
     - returns: A configured fetch request for the entity, with `defaultSortDescriptors` applied.
     - note: A `fetchBatchSize` of 20 is applied to improve performance.
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
     - parameter configure:     Optional configuration block to be applied to the fetch request.
     
     - returns: The first object matching the configured fetch request.
     */
    static func first(in context: NSManagedObjectContext, configure: FetchRequestConfigurationBlock? = nil) -> Self? {
        let request = sortedFetchRequest(configure: configure)
        request.fetchLimit = 1
        do {
            let items = try context.fetch(request)
            return items.first
        } catch {
            fatalError("Error fetching \(entityName)s: \(error)")
        }
    }
    
    /**
     - parameter context:       The context to use.
     - parameter predicate:     Optional predicate to be applied to the fetch request.
     
     - returns: The first object matching the provided predicate.
     */
    static func first(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) -> Self? {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let items = try context.fetch(request)
            return items.first
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
     Batch deletes all objects or all objects matching a predicate. An optional array of
     `NSManagedObjectContext` can be provided into which the deletions can be merged using the
     `mergeChanges(fromRemoteContextSave:into:)` function on `NSManagedObjectContext`.
     
     - This should be significantly faster than `delete(in:matching)` for large datasets.
     - This is a convenience function for calling `batchDelete(in:matching:)` on `NSEntityDescription`.
     
     - parameter context:       The context to use.
     - parameter predicate:     Optional predicate to be applied to the fetch request.
     - parameter mergeContexts: Optional contexts into which changes can be merged.
     */
    static func batchDelete(in context: NSManagedObjectContext,
                            matching predicate: NSPredicate? = nil,
                            mergingInto mergeContexts: [NSManagedObjectContext]? = nil) {
        entity().batchDelete(in: context, matching: predicate, mergingInto: mergeContexts)
    }
}

// MARK: - UniqueIdentifiable

public extension ManagedObjectType where Self: UniqueIdentifiable {
    
    /**
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - parameter uniqueID:  The unique id of the object you want to fetch.
     
     - returns: A predicate that can be used to fetch a single object with the specified unique id.
     */
    static func uniqueObjectPredicate(with uniqueKeyValue: UniqueIDType) -> NSPredicate {
        NSPredicate(equalTo: uniqueKeyValue, keyPath: uniqueIDKey)
    }
    
    /**
     Inserts an object in to the context, applies the unique id and then configures the object (optional).
     
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - parameter uniqueID:  The unique id of the object you want to insert.
     - parameter context:   The context to use.
     - parameter cache:     Optional cache to insert new object in to.
     - parameter configure: Optional configuration block to be applied to the inserted object.
     
     - returns: An initialized and configured instance of the appropriate entity (discardable).
     */
    @discardableResult
    static func insertObject(with uniqueID: UniqueIDType,
                             in context: NSManagedObjectContext,
                             with cache: ManagedObjectCache? = nil,
                             configure: ManagedObjectConfigurationBlock? = nil) -> Self {
        insertObject(in: context) { object in
            object.setValue(uniqueID, forKey: uniqueIDKey)
            cache?.register(object, in: context)
            configure?(object)
        }
    }
    
    /**
     Efficient method for fetching a single object by its unique id.
     
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - parameter uniqueID:  The unique id of the object you want to fetch.
     - parameter context:   The context to use.
     - parameter cache:     Optional cache that will be used before performing fetch.
     
     - returns: The object with the specified unique id.
     */
    static func fetchObject(with uniqueID: UniqueIDType,
                            in context: NSManagedObjectContext,
                            with cache: ManagedObjectCache? = nil) -> Self? {
        if let cachedObject: Self = cache?.object(withUniqueID: uniqueID, in: context) {
            return cachedObject
        } else if let object = first(in: context, matching: uniqueObjectPredicate(with: uniqueID)) {
            cache?.register(object, in: context)
            return object
        }
        return nil
    }
    
    /**
     Fetches an object with the specified unique id if it exists, or inserts one if it doesn't.
     
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - parameter uniqueID:  The unique id of the object you want to fetch or insert.
     - parameter context:   The context to use.
     - parameter cache:     Optional cache that will be used before performing fetch.
     - parameter configure: Configuration block, which can be used to configure the object once fetched or inserted.
     
     - returns: The object with the specified unique id.
     */
    @discardableResult
    static func fetchOrInsertObject(with uniqueID: UniqueIDType,
                                    in context: NSManagedObjectContext,
                                    with cache: ManagedObjectCache? = nil,
                                    configure: ManagedObjectConfigurationBlock? = nil) -> Self {
        if let existingObject = fetchObject(with: uniqueID, in: context, with: cache) {
            configure?(existingObject)
            return existingObject
        }
        return insertObject(with: uniqueID, in: context, with: cache, configure: configure)
    }
    
    /**
     Efficient batch insert or update adapted from Apple's Core Data Programming Guide (no longer available).
     
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - Warning: This method can create duplicates in some circumstances. If you are inserting an object that has circular dependancies, such as a parent-child relationship,
     then many additional objects will be inserted as the method caches the objects that already exist when it begins. If additional objects of the same type as being inserted are added,
     then this method will not know about them, and insert duplicates. Please see the test `testBatchInsertCreatesDuplicatesInSomeSituations` for an example.
     
     - parameter intermediates:         An array of intermediate objects (e.g. structs) that conform to UniqueIdentifiable. These will be used to create or update the Managed Objects.
     - parameter context:               The context to use.
     - parameter cache:                 Optional cache that will be used before performing fetch.
     - parameter configure:             A configuration block, called with the intermediate object and either:
     a) an existing managed object for you to update, or; 
     b) a newly inserted managed object for you to set the fields.
     In both cases the unique identifier will already be set
     */
    static func insertOrUpdate<Intermediate: UniqueIdentifiable>(intermediates: [Intermediate],
                                                                 in context: NSManagedObjectContext,
                                                                 with cache: ManagedObjectCache? = nil,
                                                                 configure: (Intermediate, Self) -> Void) where UniqueIDType == Intermediate.UniqueIDType {
        
        // Nothing to insert, exit immediately.

        guard !intermediates.isEmpty else { return }
        
        // Configure the cached objects first.
        
        var uncached: [Intermediate] = []
        
        if let cache = cache {
            intermediates.forEach { intermediate in
                if let managedObject: Self = cache.object(withUniqueID: intermediate.uniqueIDValue, in: context) {
                    configure(intermediate, managedObject)
                } else {
                    uncached.append(intermediate)
                }
            }
        } else {
            uncached = intermediates
        }
        
        // If everything was cached, exit.
        
        guard !uncached.isEmpty else { return }
        
        let predicate = NSPredicate(isIncludedIn: uncached.map { $0.uniqueIDValue }, keyPath: Self.uniqueIDKey)
        let existingObjects = fetch(in: context) { $0.predicate = predicate }
        let existingObjectsByID = Dictionary(existingObjects.map { ($0.uniqueIDValue, $0) }, uniquingKeysWith: { first, last in
            print("Error: Duplicate \(entityName) Found\n\(first)\n\(last)")
            return first
        })
        
        var managedObjectsToCache: [Self] = []
        
        uncached.forEach { intermediate in
            let intermediateID = intermediate.uniqueIDValue
            let managedObject: Self
            
            if let existing = existingObjectsByID[intermediateID] {
                managedObject = existing
            } else {
                let new = insertObject(with: intermediateID, in: context)
                managedObject = new
            }
            
            configure(intermediate, managedObject)
            
            if cache != nil { managedObjectsToCache.append(managedObject) }
        }
        
        cache?.register(managedObjectsToCache, in: context)
    }
}
