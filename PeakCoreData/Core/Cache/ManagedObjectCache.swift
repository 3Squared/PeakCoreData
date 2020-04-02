//
//  ManagedObjectCache.swift
//  PeakCoreData-iOS
//
//  Created by David Yates on 02/04/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import CoreData

/// `ManagedObjectCache` provides a way to associate the unique identifier of an `NSManagedObject`
/// with its `NSManagedObjectID` for quick access during batch inserts.
public class ManagedObjectCache {
    
    public typealias CacheableObject = (ManagedObjectType & UniqueIdentifiable)
    
    private let cache = Cache<AnyHashable, NSManagedObjectID>()
    
    public init() {}
    
    /// Returns the cached object and casts it to the specified type.
    /// - Parameters:
    ///   - uniqueID: The unique identifier of the object.
    ///   - context: The context in which the object should be returned.
    /// - Returns: The `NSManagedObject` subclass if it is cached, and nil if it is not.
    public func object<T: CacheableObject>(withUniqueID uniqueID: AnyHashable, in context: NSManagedObjectContext) -> T? {
        let key = generateKey(forUniqueID: uniqueID, entityName: T.entityName)
        guard let objectID = cache[key] else { return nil }
        return context.object(with: objectID) as? T
    }
    
    /// Returns the cached object as an `NSManagedObject`
    /// - Parameters:
    ///   - uniqueID: The unique identifier of the object.
    ///   - entityName: The name of the entity.
    ///   - context: The context in which the object should be returned.
    /// - Returns: The `NSManagedObject`if it is cached, and nil if it is not.
    public func object(with uniqueID: AnyHashable, entityName: String, in context: NSManagedObjectContext) -> NSManagedObject? {
        let key = generateKey(forUniqueID: uniqueID, entityName: entityName)
        guard let objectID = cache[key] else { return nil }
        return context.object(with: objectID)
    }
    
    /// Registers a single object in the cache. If the `NSManagedObjectID` is temporary it will be converted to a permanent ID.
    /// - Parameters:
    ///   - object: The object to be registered.
    ///   - context: The context used to obtain a permanent ID.
    public func register<T: CacheableObject>(_ object: T, in context: NSManagedObjectContext) {
        register([object], in: context)
    }
    
    /// Registers an array of objects in the cache. Any temporary `NSManagedObjectID`s will be converted to permanent IDs.
    /// - Parameters:
    ///   - objects: The objects to be registered.
    ///   - context: The context used to obtain a permanent ID.
    public func register<T: CacheableObject>(_ objects: [T], in context: NSManagedObjectContext) {
        do {
            try context.obtainPermanentIDs(for: objects)
            objects.forEach { register($0) }
        } catch {
            print("Error Obtaining Permanent ObjectID", error)
        }
    }
    
    public func removeAllObjects() {
        cache.removeAllObjects()
    }
}

extension ManagedObjectCache {
    
    private func register<T: CacheableObject>(_ object: T) {
        let key = generateKey(forUniqueID: object.uniqueIDValue, entityName: T.entityName)
        cache[key] = object.objectID
    }
    
    private func generateKey(forUniqueID uniqueID: AnyHashable, entityName: String) -> String {
        return entityName + String(uniqueID.hashValue)
    }
}
