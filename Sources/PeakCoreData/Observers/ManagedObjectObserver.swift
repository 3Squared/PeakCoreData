//
//  ManagedObjectChangeObserver.swift
//  PeakCoreData
//
//  Created by David Yates on 15/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import CoreData

public enum ManagedObjectChangeType {
    case initialised
    case refreshed
    case updated
    case deleted
}

/// Observe changes made to a managed object (refreshed, updated, deleted).
open class ManagedObjectObserver<T>: NSObject where T: ManagedObjectType {
    
    public typealias OnChange = ((T, ManagedObjectChangeType) -> Void)
    
    public var enabled: Bool = true
    public let object: T
    public var onChange: OnChange?

    private let context: NSManagedObjectContext
    private let managedObjectID: NSManagedObjectID
    
    private var notifierRunning: Bool = false

    /// Create a new ManagedObjectChangeObserver.
    /// The object will be observed in its original managedObjectContext.
    ///
    /// - Parameters:
    ///   - managedObject: The object to observe
    public convenience init(managedObject: T) {
        self.init(managedObjectID: managedObject.objectID, context: managedObject.managedObjectContext!)
    }
    
    /// Create a new ManagedObjectChangeObserver.
    ///
    /// - Parameters:
    ///   - managedObject: The object to observe
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    public convenience init(managedObject: T, context: NSManagedObjectContext) {
        self.init(managedObjectID: managedObject.objectID, context: context)
    }
    
    /// Create a new ManagedObjectChangeObserver.
    ///
    /// - Parameters:
    ///   - managedObjectID: The object ID of the object to observe
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    public init(managedObjectID: NSManagedObjectID, context: NSManagedObjectContext) {
        self.managedObjectID = managedObjectID
        self.context = context
        self.object = context.object(with: managedObjectID) as! T
        super.init()
    }
    
    
    /// Start observing changes to the count. Setting `onChange` will overwrite any previous closures that have been set.
    ///
    /// - Parameter onChange: Closure to perform whenever changes are observed
    public func startObserving(_ onChange: OnChange? = nil) {
        guard !notifierRunning else { return }

        if let onChange = onChange {
            self.onChange = onChange
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil, queue: nil) { [weak self] (note) in
            guard let self = self else { return }
            guard self.enabled else { return }
            let notification = ObjectsDidChangeNotification(notification: note)
            guard notification.managedObjectContext == self.context else { return }
            self.checkForMatchingObject(in: notification.refreshedObjects, changeType: .refreshed)
            self.checkForMatchingObject(in: notification.updatedObjects, changeType: .updated)
            self.checkForMatchingObject(in: notification.deletedObjects, changeType: .deleted)
        }
        
        onChange?(object, .initialised)
        notifierRunning = true
    }
    
    private func checkForMatchingObject(in changedObjects: Set<NSManagedObject>, changeType: ManagedObjectChangeType) {
        guard let matchingObject = changedObjects.first(where: { $0.objectID == managedObjectID }) as? T else { return }
        onChange?(matchingObject, changeType)
    }
}

extension ManagedObjectType {
    
    /// Observe changes to the managed object.
    ///
    /// - Parameter onChange: A callback called when the object is changed.
    /// - Returns: A ManagedObjectChangeObserver initialised with self as the managed object.
    public func observe(onChange: @escaping ManagedObjectObserver<Self>.OnChange) -> ManagedObjectObserver<Self> {
        let observer = ManagedObjectObserver<Self>(managedObject: self)
        observer.startObserving(onChange)
        return observer
    }
    
    /// Observe changes to the managed object.
    ///
    /// - Parameters:
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    ///   - onChange: A callback called when the object is changed.
    /// - Returns: A ManagedObjectChangeObserver initialised with self as the managed object.
    public func observe(in context: NSManagedObjectContext, onChange: @escaping ManagedObjectObserver<Self>.OnChange) -> ManagedObjectObserver<Self> {
        let observer = ManagedObjectObserver<Self>(managedObject: self, context: context)
        observer.startObserving(onChange)
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
    public func observe<T>(in context: NSManagedObjectContext, onChange: @escaping ManagedObjectObserver<T>.OnChange) -> ManagedObjectObserver<T> {
        let observer = ManagedObjectObserver<T>(managedObjectID: self, context: context)
        observer.startObserving(onChange)
        return observer
    }
}
