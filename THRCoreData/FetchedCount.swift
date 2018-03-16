//
//  FetchedCount.swift
//  THRCoreData
//
//  Created by David Yates on 15/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public class FetchedCount<T>: NSObject where T: NSManagedObject & ManagedObjectType {
    
    public typealias FetchedCountChangeListener = (Int) -> Void
    
    public var count: Int = 0
    public var onChange: FetchedCountChangeListener?

    private let predicate: NSPredicate?
    private let context: NSManagedObjectContext
    
    /// Create a new FetchedCount.
    ///
    /// - Parameters:
    ///   - fetchRequest: The fetch request used to count the objects.
    ///   - managedObjectContext: The context that will be used to count the objects.
    public init(predicate: NSPredicate?, managedObjectContext context: NSManagedObjectContext) {
        self.predicate = predicate
        self.context = context
        super.init()
        
        updateCount()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: nil, queue: nil) { [weak self] (note) in
            guard let strongSelf = self else { return }
            let date = Date()
            let notification = ContextDidSaveNotification(notification: note)
            guard notification.managedObjectContext == context else { return }
            strongSelf.updateCount()
            print(date.timeIntervalSinceNow)
        }
    }
    
    private func updateCount() {
        let newCount = T.count(in: context, matching: predicate)
        guard newCount != count else { return }
        if newCount != count {
            count = newCount
            onChange?(count)
        }
    }
}
