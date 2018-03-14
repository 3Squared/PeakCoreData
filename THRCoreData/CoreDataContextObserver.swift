//
//  CoreDataContextObserver.swift
//  THRCoreData
//
//  Created by David Yates on 14/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public struct CoreDataContextObserverState: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let inserted = CoreDataContextObserverState(rawValue: 1 << 0)
    public static let updated = CoreDataContextObserverState(rawValue: 1 << 1)
    public static let deleted = CoreDataContextObserverState(rawValue: 1 << 2)
    public static let refreshed = CoreDataContextObserverState(rawValue: 1 << 3)
    public static let all: CoreDataContextObserverState = [inserted, updated, deleted, refreshed]
}

public enum CoreDataObserverObjectChange {
    case updated(NSManagedObject)
    case refreshed(NSManagedObject)
    case inserted(NSManagedObject)
    case deleted(NSManagedObject)
    
    public func managedObject() -> NSManagedObject {
        switch self {
        case let .updated(value): return value
        case let .inserted(value): return value
        case let .refreshed(value): return value
        case let .deleted(value): return value
        }
    }
}

public struct CoreDataObserverAction<T: NSManagedObject> {
    var state: CoreDataContextObserverState
    var completionBlock: (T, CoreDataContextObserverState) -> Void
}

public class CoreDataContextObserver<T: NSManagedObject> {
    public typealias CompletionBlock = (T, CoreDataContextObserverState) -> Void
    public typealias ContextChangeBlock = (Notification, [CoreDataObserverObjectChange]) -> Void

    public var enabled: Bool = true
    public var contextChangeBlock: ContextChangeBlock?
    
    private var notificationObserver: NSObjectProtocol?
    private(set) var context: NSManagedObjectContext
    private(set) var actionsForManagedObjectID: [NSManagedObjectID: [CoreDataObserverAction<T>]] = [:]
    private(set) weak var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    deinit {
        unobserveAllObjects()
        if let notificationObserver = notificationObserver {
            NotificationCenter.default.removeObserver(notificationObserver)
        }
    }
    
    public init(context: NSManagedObjectContext) {
        self.context = context
        self.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context, queue: nil) { [weak self] notification in
            guard let strongSelf = self else { return }
            strongSelf.handleContextObjectDidChangeNotification(notification)
        }
    }
    
    private func handleContextObjectDidChangeNotification(_ notification: Notification) {
        guard let incomingContext = notification.object as? NSManagedObjectContext,
            let persistentStoreCoordinator = persistentStoreCoordinator,
            let incomingPersistentStoreCoordinator = incomingContext.persistentStoreCoordinator,
            enabled && persistentStoreCoordinator == incomingPersistentStoreCoordinator
            else { return }
        
        let insertedObjectsSet: Set<NSManagedObject> = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
        let updatedObjectsSet: Set<NSManagedObject> = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
        let deletedObjectsSet: Set<NSManagedObject> = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []
        let refreshedObjectsSet: Set<NSManagedObject> = notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject> ?? []
        
        var combinedObjectChanges = insertedObjectsSet.map { CoreDataObserverObjectChange.inserted($0) }
        combinedObjectChanges += updatedObjectsSet.map { CoreDataObserverObjectChange.updated($0) }
        combinedObjectChanges += deletedObjectsSet.map { CoreDataObserverObjectChange.deleted($0) }
        combinedObjectChanges += refreshedObjectsSet.map { CoreDataObserverObjectChange.refreshed($0) }
        
        contextChangeBlock?(notification, combinedObjectChanges)
        
        let combinedSet = insertedObjectsSet.union(updatedObjectsSet).union(deletedObjectsSet)
        let allObjectIDs = Array(actionsForManagedObjectID.keys)
        let filteredObjects = combinedSet.filter({ allObjectIDs.contains($0.objectID) })
        
        filteredObjects.forEach { (object) in
            guard let object = object as? T else { return }
            guard let actionsForObject = actionsForManagedObjectID[object.objectID] else { return }
            
            actionsForObject.forEach { (action) in
                if action.state.contains(.inserted) && insertedObjectsSet.contains(object) {
                    action.completionBlock(object, .inserted)
                } else if action.state.contains(.updated) && updatedObjectsSet.contains(object) {
                    action.completionBlock(object, .updated)
                } else if action.state.contains(.deleted) && deletedObjectsSet.contains(object) {
                    action.completionBlock(object, .deleted)
                } else if action.state.contains(.refreshed) && refreshedObjectsSet.contains(object) {
                    action.completionBlock(object, .refreshed)
                }
            }
        }
    }
    
    public func observeObject(object: T, state: CoreDataContextObserverState = .all, completionBlock: @escaping CompletionBlock) {
        let action = CoreDataObserverAction(state: state, completionBlock: completionBlock)
        if var actionArray = actionsForManagedObjectID[object.objectID] {
            actionArray.append(action)
            actionsForManagedObjectID[object.objectID] = actionArray
        } else {
            actionsForManagedObjectID[object.objectID] = [action]
        }
    }
    
    public func unobserveObject(object: T, forState state: CoreDataContextObserverState = .all) {
        if state == .all {
            actionsForManagedObjectID.removeValue(forKey: object.objectID)
        } else if let actionsForObject = actionsForManagedObjectID[object.objectID] {
            actionsForManagedObjectID[object.objectID] = actionsForObject.filter({ !$0.state.contains(state) })
        }
    }
    
    public func unobserveAllObjects() {
        actionsForManagedObjectID.removeAll()
    }
}
