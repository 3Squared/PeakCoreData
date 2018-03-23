//
//  FetchedCount.swift
//  THRCoreData
//
//  Created by David Yates on 15/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public class CountObserver<T>: NSObject where T: NSManagedObject & ManagedObjectType {
    
    public typealias OnChange = (Int) -> Void
    
    public var count: Int {
        var count: Int = 0
        context.performAndWait {
            count = T.count(in: context, matching: predicate)
        }
        return count
    }
    public var onChange: OnChange?

    private let predicate: NSPredicate?
    private let context: NSManagedObjectContext
    
    private var notifierRunning: Bool = false
    private var previousCount: Int = 0
    
    /// Create a new FetchedCount.
    ///
    /// - Parameters:
    ///   - predicate: The predicate used to count the objects.
    ///   - context: The context that will be used to count the objects.
    public init(predicate: NSPredicate?, context: NSManagedObjectContext) {
        self.predicate = predicate
        self.context = context
        super.init()
    }
    
    public func startObserving() {
        guard !notifierRunning else { return }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil, queue: nil) { [weak self] (note) in
            guard let strongSelf = self else { return }
            let notification = ObjectsDidChangeNotification(notification: note)
            guard notification.managedObjectContext == strongSelf.context else { return }
            strongSelf.contextDidChange(force: false)
        }
        contextDidChange(force: true)
        notifierRunning = true
    }
    
    private func contextDidChange(force: Bool) {
        let newCount = count
        guard force || newCount != previousCount else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.onChange?(newCount)
        }
        previousCount = newCount
    }
}
