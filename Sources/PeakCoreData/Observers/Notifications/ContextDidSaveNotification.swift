//
//  ContextDidSaveNotification.swift
//  PeakCoreData
//
//  Created by David Yates on 16/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public struct ContextDidSaveNotification {
    
    public init(notification: Notification) {
        guard notification.name == .NSManagedObjectContextDidSave else { fatalError() }
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
