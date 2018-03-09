//
//  ManagedObjectType.Swift
//  THRCoreData
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
    var managedObjectContext: NSManagedObjectContext? { get }
}

public extension ManagedObjectType {
    
    static var entityName: String {
        return String(describing: self)
    }
    
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
}

public extension ManagedObjectType where Self: NSManagedObject {
    
    typealias FetchRequestConfigurationBlock = (NSFetchRequest<Self>) -> ()
    typealias ManagedObjectConfigurationBlock = (Self) -> ()
    
    /**
     - parameter predicate:     Optional predicate to be applied to the sorted fetch request.
     
     - returns: A fetch request sorted by `defaultSortDescriptors`.
     */
    static func sortedFetchRequest(withPredicate predicate: NSPredicate? = nil) -> NSFetchRequest<Self> {
        return fetchRequest() { request in
            request.sortDescriptors = defaultSortDescriptors
            request.predicate = predicate
        }
    }
    
    /**
     - parameter configure:     Optional configuration block for the fetch request.
     
     - returns: A configured fetch request for the entity.
     */
    static func fetchRequest(withConfigurationBlock configure: FetchRequestConfigurationBlock? = nil) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        configure?(fetchRequest)
        return fetchRequest
    }
    
    /**
     - parameter context:       The context to use.
     - parameter configure:     Optional configuration block to be applied to the inserted object.
     
     - returns: An initialized and configured instance of the appropriate entity (discardable).
     */
    @discardableResult
    static func insertObject(inContext context: NSManagedObjectContext, withConfigurationBlock configure: ManagedObjectConfigurationBlock? = nil) -> Self {
        let object = Self(context: context)
        configure?(object)
        return object
    }
    
    /**
     - parameter context:       The context to use.
     - parameter configure:     Optional configuration block to be applied to the fetch request.
     
     - returns: An array of objects matching the configured fetch request.
     */
    static func fetch(inContext context: NSManagedObjectContext, withConfigurationBlock configure: FetchRequestConfigurationBlock? = nil) -> [Self] {
        let request = fetchRequest(withConfigurationBlock: configure)
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
    static func count(inContext context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate? = nil) -> Int {
        let countRequest = fetchRequest { request in
            request.predicate = predicate
        }
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
    static func delete(inContext context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate? = nil) {
        let itemsToDelete = fetch(inContext: context) { fetchRequest in
            fetchRequest.predicate = predicate
            fetchRequest.includesPropertyValues = false
        }
        itemsToDelete.forEach { context.delete($0) }
    }
}

// MARK: - UniqueIdentifiable

public extension ManagedObjectType where Self: NSManagedObject, Self: UniqueIdentifiable {
    
    /**
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - parameter uniqueKeyValue:    The unique id of the object you want to fetch.
     
     - returns: A predicate that can be used to fetch a single object with the specified unique id.
     */
    static func uniqueObjectPredicate(withUniqueKeyValue uniqueKeyValue: Any) -> NSPredicate {
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
    static func insertObject(withUniqueKeyValue uniqueKeyValue: Any, inContext context: NSManagedObjectContext, configure: ManagedObjectConfigurationBlock? = nil) -> Self {
        return insertObject(inContext: context) { object in
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
    static func fetchObject(withUniqueKeyValue uniqueKeyValue: Any, inContext context: NSManagedObjectContext) -> Self? {
        let predicate = uniqueObjectPredicate(withUniqueKeyValue: uniqueKeyValue)
        return fetch(inContext: context) { request in
            request.predicate = predicate
            request.returnsObjectsAsFaults = false
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
    static func fetchOrInsertObject(withUniqueKeyValue uniqueKeyValue: Any, inContext context: NSManagedObjectContext, withConfigurationBlock configure: ManagedObjectConfigurationBlock? = nil) -> Self {
        guard let existingObject = fetchObject(withUniqueKeyValue: uniqueKeyValue, inContext: context) else {
            return insertObject(withUniqueKeyValue: uniqueKeyValue, inContext: context, configure: configure)
        }
        configure?(existingObject)
        return existingObject
    }
    
    /**
     Efficient batch insert or update adapted from Apple's Core Data Programming Guide (no longer available).
     
     - Note: The managed object must conform to UniqueIdentifiable.
     
     - Warning: Please limit the Core Data operations that you perform in the closure block. For maximum performance, set properties ONLY.
     This method can create duplicates in some circumstances. If you are inserting an object that has circular dependancies, such as a parent-child relationship, then many additional objects will be inserted as the method caches the objects that already exist when it begins. If additional objects of the same type as being inserted are added, then this method will not know about them, and insert duplicates. Please see the test `testBatchInsertCreatesDuplicatesInSomeSituations` for an example.
     
     - parameter intermediates:         An array of intermediate objects (e.g. structs) that conform to UniqueIdentifiable. These will be used to create or update the Managed Objects.
     - parameter context:               The context to use.
     - parameter configureProperties:   A configuration block, called with the intermediate object and either:
     a) an existing managed object for you to update, or; 
     b) a newly inserted managed object for you to set the fields.
     In both cases the unique identifier will already be set
     */
    static func insertOrUpdate<IntermediateType: UniqueIdentifiable>(intermediates: [IntermediateType], inContext context: NSManagedObjectContext, configureProperties: (IntermediateType, Self) -> ()) {
        
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
        
        let request = fetchRequest { fetchRequest in
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
                configureProperties(intermediate!, existingObject)
                managedObject = managedObjectIterator.next()
            } else {
                let newObject = insertObject(withUniqueKeyValue: intermediateID, inContext: context)
                configureProperties(intermediate!, newObject)
            }
            intermediate = intermediatesIterator.next()
        }
    }
}
