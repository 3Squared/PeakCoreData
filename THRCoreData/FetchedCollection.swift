//
//  FetchedCollection.swift
//  THRCoreData
//
//  Created by Sam Oakley on 19/01/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//
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
        return dataProvider.sections
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
    
    public func reconfigureFetchRequest(_ configure: (NSFetchRequest<T>) -> ()) {
        dataProvider.reconfigureFetchRequest(configure)
    }
    
    /// Create a static array from the currently fetched objects.
    /// These objects may still set to isDeleted, but the size of the array will not change.
    ///
    /// - Returns: An array of managedObjects.
    public func snapshot() -> [T] {
        return Array(self)
    }
}

// MARK: - Collection

extension FetchedCollection: Collection {
    
    public var startIndex: IndexPath {
        return IndexPath(item: 0, section: 0)
    }
    
    public var endIndex: IndexPath {
        // This method expects the "past the end"-end. So, the count.
        let lastSection = dataProvider.numberOfSections - 1
        let lastItemInSection = dataProvider.sectionInfo(forSection: lastSection).numberOfObjects
        return IndexPath(item: lastItemInSection, section: lastSection)
    }
    
    public subscript (position: IndexPath) -> T {
        precondition((startIndex ..< endIndex).contains(position), "out of bounds")
        return dataProvider.object(at: position)
    }
    
    subscript (position: (item: Int, section: Int)) -> T {
        let index = IndexPath(item: position.item, section: position.section)
        precondition((startIndex ..< endIndex).contains(index), "out of bounds")
        return dataProvider.object(at: index)
    }
    
    public func index(after i: IndexPath) -> IndexPath {
        // Get the overall index of the item in all fetched objects
        // Then get the item immediately following it
        // Then get that item's index path
        
        // This should deal with the situation when the next object
        // is in a different section, so we can't just increment `item`
        
        let currentObject = dataProvider.object(at: i)
        let index = dataProvider.fetchedObjects.index(of: currentObject)! as Int
        let nextIndex = index + 1
        
        if nextIndex < dataProvider.fetchedObjectsCount {
            let nextObject = dataProvider.fetchedObjects[nextIndex]
            return dataProvider.indexPath(forObject: nextObject)!
        }
        
        return IndexPath(item: i.item + 1, section: i.section)
    }
}

extension FetchedCollection: FetchedDataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [FetchedUpdate<T>]?) {
        onChange?(self, updates)
    }
}
