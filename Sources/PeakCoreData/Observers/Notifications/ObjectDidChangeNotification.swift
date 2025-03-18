//
//  File.swift
//  PeakCoreData
//
//  Created by David Yates on 15/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import CoreData

public struct ObjectsDidChangeNotification {
    
    init(notification: Notification) {
        assert(notification.name == .NSManagedObjectContextObjectsDidChange)
        self.notification = notification
    }
    
    public var insertedObjects: Set<NSManagedObject> {
        objects(forKey: NSInsertedObjectsKey)
    }
    
    public var updatedObjects: Set<NSManagedObject> {
        objects(forKey: NSUpdatedObjectsKey)
    }
    
    public var deletedObjects: Set<NSManagedObject> {
        objects(forKey: NSDeletedObjectsKey)
    }
    
    public var refreshedObjects: Set<NSManagedObject> {
        objects(forKey: NSRefreshedObjectsKey)
    }
    
    public var invalidatedObjects: Set<NSManagedObject> {
        objects(forKey: NSInvalidatedObjectsKey)
    }
    
    public var invalidatedAllObjects: Bool {
        (notification as Notification).userInfo?[NSInvalidatedAllObjectsKey] != nil
    }
    
    public var managedObjectContext: NSManagedObjectContext {
        guard let context = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return context
    }
    
    // MARK: Private
    
    private let notification: Notification
    
    private func objects(forKey key: String) -> Set<NSManagedObject> {
        (notification.userInfo?[key] as? Set<NSManagedObject>) ?? []
    }
}
