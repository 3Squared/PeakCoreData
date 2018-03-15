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
    
    /// Use to turn change tracking on and off
    public var enabled: Bool = true
    public let object: T

    private let context: NSManagedObjectContext
    private let onChange: OnChange
    private let objectID: NSManagedObjectID

    /// Create a new ManagedObjectChangeObserver.
    /// The object will be observed in its original managedObjectContext.
    ///
    /// - Parameters:
    ///   - managedObject: The object to observe
    ///   - onChange: A callback called when the object is changed.
    public convenience init(with managedObject: T, onChange: @escaping OnChange) {
        self.init(with: managedObject.objectID, in: managedObject.managedObjectContext!, onChange: onChange)
    }
    
    /// Create a new ManagedObjectChangeObserver.
    ///
    /// - Parameters:
    ///   - managedObject: The object to observe
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    ///   - onChange: A callback called when the object is changed.
    public convenience init(with managedObject: T, in context: NSManagedObjectContext, onChange: @escaping OnChange) {
        self.init(with: managedObject.objectID, in: context, onChange: onChange)
    }
    
    public init(with objectID: NSManagedObjectID, in context: NSManagedObjectContext, onChange: @escaping OnChange) {
        self.objectID = objectID
        self.context = context
        self.onChange = onChange
        self.object = context.object(with: objectID) as! T
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil, queue: nil) { (note) in
            guard self.enabled else { return }
            let notification = ObjectsDidChangeNotification(notification: note)
            guard notification.managedObjectContext == context else { return }
            self.checkForMatchingObject(in: notification.refreshedObjects, changeType: .refreshed)
            self.checkForMatchingObject(in: notification.updatedObjects, changeType: .updated)
            self.checkForMatchingObject(in: notification.deletedObjects, changeType: .deleted)
        }
    }
    
    private func checkForMatchingObject(in changedObjects: Set<NSManagedObject>, changeType: ManagedObjectChangeType) {
        guard let matchingObject = changedObjects.first(where: { $0.objectID == objectID }) as? T else { return }
        onChange(matchingObject, changeType)
    }
}

extension ManagedObjectType where Self: NSManagedObject {
    
    /// Observe changes to the managed object.
    ///
    /// - Parameter onChange: A callback called when the object is changed.
    /// - Returns: A ManagedObjectChangeObserver initialised with self as the managed object.
    @discardableResult
    public func observe(onChange: @escaping ManagedObjectChangeObserver<Self>.OnChange) -> ManagedObjectChangeObserver<Self> {
        return ManagedObjectChangeObserver<Self>(with: self, onChange: onChange)
    }
    
    /// Observe changes to the managed object.
    ///
    /// - Parameters:
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    ///   - onChange: A callback called when the object is changed.
    /// - Returns: A ManagedObjectChangeObserver initialised with self as the managed object.
    @discardableResult
    public func observe(in context: NSManagedObjectContext, onChange: @escaping ManagedObjectChangeObserver<Self>.OnChange) -> ManagedObjectChangeObserver<Self> {
        return ManagedObjectChangeObserver<Self>(with: self, in: context, onChange: onChange)
    }
}

extension NSManagedObjectID {
    
    /// Observe changes to the managed object referred to by the ID.
    ///
    /// - Parameters:
    ///   - context: The context that will hold the fetched object.
    ///   - onChange: A callback called when the object is changed.
    /// - Returns: A ManagedObjectChangeObserver initialised with the managed object referred to by the ID.
    @discardableResult
    public func observe<T>(in context: NSManagedObjectContext, onChange: @escaping ManagedObjectChangeObserver<T>.OnChange) -> ManagedObjectChangeObserver<T> {
        return ManagedObjectChangeObserver<T>(with: self, in: context, onChange: onChange)
    }
}
