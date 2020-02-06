//
//  ManagedObjectCache.swift
//  PeakCoreData-iOS
//
//  Created by David Yates on 05/02/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import CoreData

public class ManagedObjectCache {
    
    public typealias CacheableObject = (ManagedObjectType & UniqueIdentifiable)
    
    private let cache = Cache<AnyHashable, NSManagedObjectID>()
    
    public init() {}
    
    public func object<T: CacheableObject>(withUniqueID uniqueID: AnyHashable, in context: NSManagedObjectContext) -> T? {
        let key = generateKey(forUniqueID: uniqueID, entityName: T.entityName)
        guard let objectID = cache[key] else { return nil }
        return context.object(with: objectID) as? T
    }
    
    public func register<T: CacheableObject>(_ object: T, in context: NSManagedObjectContext) {
        do {
            try context.obtainPermanentIDs(for: [object])
            let key = generateKey(forUniqueID: object.uniqueIDValue, entityName: T.entityName)
            cache[key] = object.objectID
        } catch {
            print("Error Obtaining Permanent ObjectID", error)
        }
    }
    
    public func removeAllObjects() {
        cache.removeAllObjects()
    }
}

extension ManagedObjectCache {
    
    private func generateKey(forUniqueID uniqueID: AnyHashable, entityName: String) -> String { entityName + String(uniqueID.hashValue) }
}
