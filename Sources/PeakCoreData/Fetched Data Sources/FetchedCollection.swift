//
//  FetchedCollection.swift
//  PeakCoreData
//
//  Created by Sam Oakley on 19/01/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

#if canImport(UIKit)

import Foundation
import CoreData

/// A wrapper for NSFetchedResultsController.
public class FetchedCollection<T: NSManagedObject>: NSObject {
        
    public typealias FetchedCollectionChangeListener = (FetchedCollection<T>, [FetchedUpdate<T>]?) -> Void
    
    public var onChange: FetchedCollectionChangeListener? {
        didSet {
            onChange?(self, nil)
        }
    }
    
    private let dataProvider: FetchedDataProvider<FetchedCollection>
    
    public var sections: [NSFetchedResultsSectionInfo] {
        dataProvider.sections
    }
    
    public func object(at indexPath: IndexPath) -> T {
        dataProvider.object(at: indexPath)
    }
    
    public func index(of object: T) -> IndexPath? {
        dataProvider.indexPath(forObject: object)
    }
    
    public var count: Int {
        dataProvider.fetchedObjectsCount
    }
    
    public func snapshot() -> [T] {
        dataProvider.fetchedObjects
    }
    
    public var isEmpty: Bool {
        dataProvider.fetchedObjectsCount == 0
    }
    
    /// Create a new FetchedCollection.
    ///
    /// - Parameters:
    ///   - fetchRequest: The fetch request used to get the objects. It's expected that the sort descriptor used in the request groups the objects into sections.
    ///   - context: The context that will hold the fetched objects.
    ///   - sectionNameKeyPath: A keypath on resulting objects that returns the section name. This will be used to pre-compute the section information.
    ///   - cacheName: Section info is cached persistently to a private file under this name. Cached sections are checked to see if the time stamp matches the store, but not if you have illegally mutated the readonly fetch request, predicate, or sort descriptor.
    public init(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext, sectionNameKeyPath: String? = nil, cacheName: String? = nil) {
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: sectionNameKeyPath,
                                             cacheName: cacheName)
        self.dataProvider = FetchedDataProvider(fetchedResultsController: frc)
        super.init()
        dataProvider.delegate = self
        dataProvider.performFetch()
    }
    
    public func reconfigureFetchRequest(_ configure: (NSFetchRequest<T>) -> Void) {
        dataProvider.reconfigureFetchRequest(configure)
    }

}

extension FetchedCollection {
    
    public subscript (position: IndexPath) -> T {
        dataProvider.object(at: position)
    }
    
    public subscript (position: (item: Int, section: Int)) -> T {
        dataProvider.object(at: IndexPath(item: position.item, section: position.section))
    }
    
    public subscript (item: Int, section: Int) -> T {
        dataProvider.object(at: IndexPath(item: item, section: section))
    }
}

extension FetchedCollection: FetchedDataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [FetchedUpdate<T>]?) {
        onChange?(self, updates)
    }
}

#endif
