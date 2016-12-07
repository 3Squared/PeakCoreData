//
//  ManagedObjectType.Swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

// Source: https://www.objc.io/books/core-data/

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

    static func sortedFetchRequest(withPredicate predicate: NSPredicate? = nil) -> NSFetchRequest<Self> {
        return fetchRequest(withConfigurationBlock: { (request) in
            request.fetchBatchSize = 20
            request.sortDescriptors = defaultSortDescriptors
            request.predicate = predicate
        })
    }

    static func fetchRequest(withConfigurationBlock configurationBlock: FetchRequestConfigurationBlock = { _ in }) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        configurationBlock(fetchRequest)
        return fetchRequest
    }
    
    @discardableResult
    static func insert(inContext context: NSManagedObjectContext, configurationBlock: ManagedObjectConfigurationBlock = { _ in }) -> Self {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context) as? Self else { fatalError("Wrong object type") }
        configurationBlock(object)
        return object
    }
    
    static func fetch(inContext context: NSManagedObjectContext, configurationBlock: FetchRequestConfigurationBlock = { _ in }) -> [Self] {
        let request = fetchRequest(withConfigurationBlock: configurationBlock)
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Error fetching \(entityName)s: \(error)")
        }
    }
    
    static func count(inContext context: NSManagedObjectContext, configurationBlock: FetchRequestConfigurationBlock = { _ in }) -> Int {
        let request = fetchRequest(withConfigurationBlock: configurationBlock)
        do {
            return try context.count(for: request)
        } catch {
            fatalError("Error counting \(entityName)s: \(error)")
        }
    }

    static func materialiseObject(inContext context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }
    
    static func deleteAll(inContext context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate? = nil) {
        let itemsToDelete = Self.fetch(inContext: context) {
            fetchRequest in
            fetchRequest.predicate = predicate
            fetchRequest.includesPropertyValues = false
        }
        for item in itemsToDelete {
            context.delete(item)
        }
    }
}

public extension ManagedObjectType where Self: NSManagedObject, Self: UniqueIdentifiable {
    
    static func uniquePredicate(withUniqueKeyValue uniqueKeyValue: Any) -> NSPredicate {
        return NSPredicate(format: "%K == %@", argumentArray: [Self.uniqueIDKey, uniqueKeyValue])
    }
    
    /**
     Fetches an object with the specified unique id if it exists, or creates one if it doesn't.
     
     - Note:
     Managed Object must conform to UniqueIdentifiable.
     
     - Parameters:
        - uniqueKeyValue: The unique id value of the object you wish to fetch or insert
        - context: The context in which to operate
     */
    @discardableResult
    static func insertOrFetchObject(withUniqueKeyValue uniqueKeyValue: Any, inContext context: NSManagedObjectContext, configurationBlock: ManagedObjectConfigurationBlock = { _ in }) -> Self {
        guard let existingObject = fetchObject(withUniqueKeyValue: uniqueKeyValue, inContext: context) else {
            return Self.insert(inContext: context, configurationBlock: { (object) in
                object.setValue(uniqueKeyValue, forKey: uniqueIDKey)
                configurationBlock(object)
            })
        }
        configurationBlock(existingObject)
        return existingObject
    }
    
    /**
     Efficient method for fetching a single object by its unique identifier.
     
     - Note:
     Managed Object must conform to UniqueIdentifiable.
     
     - Parameters:
        - uniqueKeyValue: The unique id value of the object you wish to fetch
        - context: The context in which to operate
    */
    
    static func fetchObject(withUniqueKeyValue uniqueKeyValue: Any, inContext context: NSManagedObjectContext) -> Self? {
        let predicate = uniquePredicate(withUniqueKeyValue: uniqueKeyValue)
        guard let object = materialiseObject(inContext: context, matchingPredicate: predicate) else {
            return fetch(inContext: context, configurationBlock: { (request) in
                request.predicate = predicate
                request.fetchLimit = 1
            }).first
        }
        return object
    }
    
    /**
     Efficient find-or-create adapted from Apple's Core Data Programming Guide (no longer available).
     
     - Note:
     Managed Object must conform to UniqueIdentifiable.
     
     - Warning:
     You should avoid initiating any Core Data operations in the closure block. You should only apply the logic necessary to set the properties of the managed object.
     
     - Parameters:
        - intermediates: An array of intermediate objects (e.g. structs) that conform to UniqueIdentifiable. These will be used to create or update the Managed Objects.
        - context: The context in which to operate
        - configureProperties: A block called with the intermediate and either:
            a) an existing managed object for you to update, or;
            b) a newly inserted managed object for you to set the fields.
            Both cases can be treated the same - both will have their ID already set.
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
                let newObject = Self.insert(inContext: context, configurationBlock: { (object) in
                    object.setValue(intermediateID, forKey: uniqueIDKey)
                })
                configureProperties(intermediate!, newObject)
            }
            intermediate = intermediatesIterator.next()
        }
    }
}
