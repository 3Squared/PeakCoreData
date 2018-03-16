//
//  FetchedCount.swift
//  THRCoreData
//
//  Created by David Yates on 15/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public class FetchedCount<T: NSManagedObject>: NSObject {
    
    public typealias FetchedCountChangeListener = (Int) -> Void
    
    public var count: Int!
    public var onChange: FetchedCountChangeListener?

    private let fetchRequest: NSFetchRequest<T>
    private let context: NSManagedObjectContext
    private let dataProvider: FetchedDataProvider<FetchedCount>!
    
    /// Create a new FetchedCount.
    ///
    /// - Parameters:
    ///   - fetchRequest: The fetch request used to count the objects.
    ///   - managedObjectContext: The context that will be used to count the objects.
    public init(fetchRequest: NSFetchRequest<T>, managedObjectContext context: NSManagedObjectContext) {
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.includesPropertyValues = false
        fetchRequest.includesSubentities = false
        self.fetchRequest = fetchRequest
        self.context = context
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        self.dataProvider = FetchedDataProvider(fetchedResultsController: frc)
        super.init()
        updateCount()
        dataProvider.delegate = self
        dataProvider.performFetch()
    }
    
    public func reconfigureFetchRequest(_ configure: (NSFetchRequest<T>) -> ()) {
        dataProvider.reconfigureFetchRequest(configure)
    }
    
    private func updateCount() {
        count = try! context.count(for: fetchRequest)
    }
}

extension FetchedCount: FetchedDataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [FetchedUpdate<T>]?) {
        updateCount()
        onChange?(count)
    }
}
