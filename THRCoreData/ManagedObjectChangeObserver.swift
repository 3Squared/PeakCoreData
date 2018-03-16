//
//  ManagedObjectChangeObserver.swift
//  THRCoreData
//
//  Created by David Yates on 15/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import CoreData

public enum ManagedObjectChangeType {
    case refreshed
    case updated
    case deleted
}

/// Observe changes made to a managed object (refreshed, updated, deleted).
open class ManagedObjectChangeObserver<T> where T: NSManagedObject & ManagedObjectType {
    
    public typealias OnChange = ((T, ManagedObjectChangeType) -> Void)
    
    public var onChange: OnChange?

    /// Use to turn change tracking on and off
    public var enabled: Bool = true
    public let object: T

    private let context: NSManagedObjectContext
    private let objectID: NSManagedObjectID

    /// Create a new ManagedObjectChangeObserver.
    /// The object will be observed in its original managedObjectContext.
    ///
    /// - Parameters:
    ///   - managedObject: The object to observe
    public convenience init(with managedObject: T) {
        self.init(with: managedObject.objectID, in: managedObject.managedObjectContext!)
    }
    
    /// Create a new ManagedObjectChangeObserver.
    ///
    /// - Parameters:
    ///   - managedObject: The object to observe
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    public convenience init(with managedObject: T, in context: NSManagedObjectContext) {
        self.init(with: managedObject.objectID, in: context)
    }
    
    /// Create a new ManagedObjectChangeObserver.
    ///
    /// - Parameters:
    ///   - objectID: The object ID of the object to observe
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    public init(with objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
        self.objectID = objectID
        self.context = context
        self.object = context.object(with: objectID) as! T
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil, queue: nil) { [weak self] (note) in
            guard let strongSelf = self else { return }
            guard strongSelf.enabled else { return }
            let notification = ObjectsDidChangeNotification(notification: note)
            guard notification.managedObjectContext == context else { return }
            strongSelf.checkForMatchingObject(in: notification.refreshedObjects, changeType: .refreshed)
            strongSelf.checkForMatchingObject(in: notification.updatedObjects, changeType: .updated)
            strongSelf.checkForMatchingObject(in: notification.deletedObjects, changeType: .deleted)
        }
    }
    
    private func checkForMatchingObject(in changedObjects: Set<NSManagedObject>, changeType: ManagedObjectChangeType) {
        guard let matchingObject = changedObjects.first(where: { $0.objectID == objectID }) as? T else { return }
        onChange?(matchingObject, changeType)
    }
}

extension ManagedObjectType where Self: NSManagedObject {
    
    /// Observe changes to the managed object.
    ///
    /// - Parameter onChange: A callback called when the object is changed.
    /// - Returns: A ManagedObjectChangeObserver initialised with self as the managed object.
    public func observe(onChange: @escaping ManagedObjectChangeObserver<Self>.OnChange) -> ManagedObjectChangeObserver<Self> {
        let observer = ManagedObjectChangeObserver<Self>(with: self)
        observer.onChange = onChange
        return observer
    }
    
    /// Observe changes to the managed object.
    ///
    /// - Parameters:
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    ///   - onChange: A callback called when the object is changed.
    /// - Returns: A ManagedObjectChangeObserver initialised with self as the managed object.
    public func observe(in context: NSManagedObjectContext, onChange: @escaping ManagedObjectChangeObserver<Self>.OnChange) -> ManagedObjectChangeObserver<Self> {
        let observer = ManagedObjectChangeObserver<Self>(with: self, in: context)
        observer.onChange = onChange
        return observer
    }
}

extension NSManagedObjectID {
    
    /// Observe changes to the managed object referred to by the ID.
    ///
    /// - Parameters:
    ///   - context: The context that will hold the fetched object.
    ///   - onChange: A callback called when the object is changed.
    /// - Returns: A ManagedObjectChangeObserver initialised with the managed object referred to by the ID.
    public func observe<T>(in context: NSManagedObjectContext, onChange: @escaping ManagedObjectChangeObserver<T>.OnChange) -> ManagedObjectChangeObserver<T> {
        let observer = ManagedObjectChangeObserver<T>(with: self, in: context)
        observer.onChange = onChange
        return observer
    }
}
