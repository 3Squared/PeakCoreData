//
//  FetchedCount.swift
//  PeakCoreData
//
//  Created by David Yates on 15/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public class CountObserver<T>: NSObject where T: ManagedObjectType {
    
    public typealias OnChange = (Int) -> Void
    
    public var enabled: Bool = true
    public var onChange: OnChange?
    public var count: Int {
        var count: Int = 0
        context.performAndWait {
            count = T.count(in: context, matching: predicate)
        }
        return count
    }
    
    private let context: NSManagedObjectContext
    private let predicate: NSPredicate?
    
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
            self.contextDidChange(force: false)
        }
        contextDidChange(force: true)
        notifierRunning = true
    }
    
    private func contextDidChange(force: Bool) {
        let newCount = count
        guard force || newCount != previousCount else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onChange?(newCount)
        }
        previousCount = newCount
    }
}
