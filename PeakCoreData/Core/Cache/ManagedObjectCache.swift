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
    
    /// The name of the cache. Default value is an empty string.
    public var name: String {
        set { cache.name = newValue }
        get { return cache.name }
    }
    
    /// The maximum number of objects the cache should hold. Default value is 0 (no limit).
    public var countLimit: Int {
        set { cache.countLimit = newValue }
        get { return cache.countLimit }
    }
    
    /// The maximum total cost that the cache can hold before it starts evicting objects.
    public var totalCostLimit: Int {
        set { cache.totalCostLimit = newValue }
        get { return cache.totalCostLimit }
    }
    
    /// Called when an NSManagedObjectID is about to be evicted or removed from the cache.
    public var onObjectEviction: ((NSManagedObjectID) -> Void)? {
        didSet {
            cache.onObjectEviction = onObjectEviction
        }
    }
    
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
    
    /// Removes the value of the specified key in the cache.
    public func removeValue(forKey key: AnyHashable) {
        cache.removeValue(forKey: key)
    }
    
    /// Empties the cache.
    public func clearCache() {
        cache.clearCache()
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
