//
//  FetchedCollection.swift
//  THRCoreData
//
//  Created by Sam Oakley on 19/01/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//
import Foundation
import CoreData
import THRResult

/// Implement this protocal to indicate that your viewController's tableview can be updated by DataProviderUpdates
public protocol DataProviderUpdatable {
    associatedtype ManagedObject: ManagedObjectType
    associatedtype Cell: UITableViewCell
    
    /// Configure a cell for display based on a given managed object.
    ///
    /// - Parameters:
    ///   - cell: The cell to configure.
    ///   - object: The managedObject from which to set the cell's views.
    func configure(cell: Cell, forObject object: ManagedObject)
}

public extension DataProviderUpdatable where Self: UIViewController {
    
    /// Call this method to animate the tableview from the provided changes.
    /// Ensure that numberOfSections and numberOfRowsInSection return the appropriate values before the updates.
    ///
    /// - Parameters:
    ///   - updates: A list of DataProviderUpdates.
    ///   - tableView: A tableview.
    ///   - animation: The animation with which to perform the updates.
    public func process(updates: [DataProviderUpdate<ManagedObject>]?, for tableView: UITableView, with animation: UITableViewRowAnimation = .automatic) {
        if let updates = updates {
            let updateBlock = {
                for update in updates {
                    switch update {
                    case .insert(let indexPath):
                        tableView.insertRows(at: [indexPath as IndexPath], with: animation)
                    case .update(let indexPath, let object):
                        guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { break }
                        self.configure(cell: cell, forObject: object)
                    case .move(let fromIndexPath, let toIndexPath):
                        tableView.deleteRows(at: [fromIndexPath as IndexPath], with: animation)
                        tableView.insertRows(at: [toIndexPath as IndexPath], with: animation)
                    case .delete(let indexPath):
                        tableView.deleteRows(at: [indexPath as IndexPath], with: animation)
                    case .insertSection(let section):
                        let indexSet = IndexSet(integer: section)
                        tableView.insertSections(indexSet, with: animation)
                    case .deleteSection(let section):
                        let indexSet = IndexSet(integer: section)
                        tableView.deleteSections(indexSet, with: animation)
                    }
                }
            }
            
            if animation == .none {
                UIView.setAnimationsEnabled(false)
            }
            
            if #available(iOS 11.0, *) {
                tableView.performBatchUpdates(updateBlock)
            } else {
                tableView.beginUpdates()
                updateBlock()
                tableView.endUpdates()
            }
            
            if animation == .none {
                UIView.setAnimationsEnabled(true)
            }
        } else {
            tableView.reloadData()
        }
    }
}

/// Observe changes made to a managed object. Uses FetchedCollection.
public class FetchedObjectObserver<T> where T: NSManagedObject, T: ManagedObjectType {
    
    public typealias FetchedObjectChangeListener = (T?) -> Void

    private var fetchedCollection: FetchedCollection<T>!
    
    public var onChange: FetchedObjectChangeListener!
    
    /// The managed object being observed.
    private(set) public var object: T?
    
    
    /// Create a new FetchedObjectObserver.
    /// The object will be observed in its original managedObjectContext.
    ///
    /// - Parameters:
    ///   - managedObject: The object to observe
    ///   - onChange: A callback called when the object is changed.
    public convenience init(with managedObject: T, onChange: @escaping FetchedObjectChangeListener) {
        self.init(with: managedObject.objectID, in: managedObject.managedObjectContext!, onChange: onChange)
    }
    
    
    /// Create a new FetchedObjectObserver.
    ///
    /// - Parameters:
    ///   - managedObject: The object to observe
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    ///   - onChange: A callback called when the object is changed.
    public convenience init(with managedObject: T, in context: NSManagedObjectContext, onChange: @escaping FetchedObjectChangeListener) {
        self.init(with: managedObject.objectID, in: context, onChange: onChange)
    }
    
    
    /// Create a new FetchedObjectObserver.
    ///
    /// - Parameters:
    ///   - id: The managed object ID of the object to observe
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    ///   - onChange: A callback called when the object is changed.
    public init(with id: NSManagedObjectID, in context: NSManagedObjectContext, onChange: @escaping FetchedObjectChangeListener) {
        object = context.object(with: id) as? T
        
        let fetchRequest = T.fetchRequest { request in
            request.fetchLimit = 1
            request.sortDescriptors = T.defaultSortDescriptors
            request.predicate = NSPredicate(format: "SELF == %@", id)
        }
        
        defer {
            fetchedCollection = FetchedCollection(fetchRequest: fetchRequest, managedObjectContext: context) { result, update in
                if update != nil {
                    let objects = try? result.resolve()
                    self.object = (objects != nil && objects?.count == 1) ? objects?.first : nil
                    onChange(self.object)
                }
            }
        }
    }

    /// Release the fetchedResultsController's delegate.
    public func cleanUp() {
        fetchedCollection.cleanUp()
    }
}

public extension ManagedObjectType where Self: NSManagedObject {
    
    /// Observe changes to the managed object.
    ///
    /// - Parameter onChange: A callback called when the object is changed.
    /// - Returns: A FetchedObjectObserver initialised with self as the managed object.
    public func observe(onChange: @escaping (Self?) -> Void) -> FetchedObjectObserver<Self> {
        return observe(in: managedObjectContext!, onChange: onChange)
    }
    
    /// Observe changes to the managed object.
    ///
    /// - Parameters:
    ///   - context: The context that will hold the fetched object. It will first be fetched from this context, so it may differ from its original.
    ///   - onChange: A callback called when the object is changed.
    /// - Returns: A FetchedObjectObserver initialised with self as the managed object.
    public func observe(in context: NSManagedObjectContext, onChange: @escaping (Self?) -> Void) -> FetchedObjectObserver<Self> {
        return FetchedObjectObserver(with: self, in: context, onChange: onChange)
    }
}

public extension NSManagedObjectID {
    
    /// Observe changes to the managed object referred to by the ID.
    ///
    /// - Parameters:
    ///   - context: The context that will hold the fetched object.
    ///   - onChange: A callback called when the object is changed.
    /// - Returns: A FetchedObjectObserver initialised with the managed object referred to by the ID.
    public func observe<T>(in context: NSManagedObjectContext, onChange: @escaping (T?) -> Void) -> FetchedObjectObserver<T> where T: NSManagedObject, T: ManagedObjectType {
        return FetchedObjectObserver(with: self, in: context, onChange: onChange)
    }
}

/// A wrapper for NSFetchedResultsController.
public class FetchedCollection<T: NSManagedObject>: NSObject, Collection, NSFetchedResultsControllerDelegate {
    
    public typealias FetchedCollectionChangeListener = (Result<FetchedCollection<T>>, [DataProviderUpdate<T>]?) -> Void
    
    public var onChange: FetchedCollectionChangeListener!
    public private(set) var sections: [Section<T>] = []
    
    private let frc: NSFetchedResultsController<T>
    private var updates: [DataProviderUpdate<T>] = []
    
    
    /// Create a new FetchedCollection.
    ///
    /// - Parameters:
    ///   - fetchRequest: The fetch request used to get the objects. It's expected that the sort descriptor used in the request groups the objects into sections.
    ///   - managedObjectContext: The context that will hold the fetched objects
    ///   - sectionNameKeyPath: A keypath on resulting objects that returns the section name. This will be used to pre-compute the section information.
    ///   - cacheName: Section info is cached persistently to a private file under this name. Cached sections are checked to see if the time stamp matches the store, but not if you have illegally mutated the readonly fetch request, predicate, or sort descriptor.
    ///   - onChange: A callback called when the data matching the fetchRequest is changed.
    public init(fetchRequest: NSFetchRequest<T>,
                managedObjectContext context: NSManagedObjectContext,
                sectionNameKeyPath: String? = nil,
                cacheName: String? = nil,
                onChange: @escaping FetchedCollectionChangeListener = {_,_ in }) {
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: context,
                                              sectionNameKeyPath: sectionNameKeyPath,
                                              cacheName: cacheName)
        super.init()
        
        self.onChange = onChange
        self.frc.delegate = self
        performFetch()
    }
    
    
    private func updateSections() {
        self.sections = self.frc.sections!.map { info in
            return Section(name: info.name,
                           indexTitle: info.indexTitle,
                           numberOfObjects: info.numberOfObjects)
        }
    }
    
    private func performFetch() {
        frc.managedObjectContext.performAndWait {
            let result = Result { () -> FetchedCollection<T> in
                try self.frc.performFetch()
                self.updateSections()
                return self
            }
            self.onChange(result, nil)
        }
    }
    
    
    /// Provides a way to modify the backing fetch request.
    /// A new fetch will be performed.
    ///
    /// - Parameter block: A block which allows you to edit the fetchRequest.
    public func reconfigureFetchRequest(block: (NSFetchRequest<T>) -> ()) {
        NSFetchedResultsController<T>.deleteCache(withName: frc.cacheName)
        block(frc.fetchRequest)
        performFetch()
    }
    
    override public var debugDescription: String {
        return "CoreDataResults{ size = \(self.count), \(frc) }"
    }
    
    /// Release the fetchedResultsController's delegate.
    func cleanUp() {
        frc.delegate = nil
    }
    
    // MARK: Collection
    
    public var startIndex: IndexPath {
        return IndexPath(item: 0, section: 0)
    }
    
    public var endIndex: IndexPath {
        // This method expects the "past the end"-end. So, the count.
        if let sections = self.frc.sections {
            let lastSection = sections.count - 1
            let lastItemInSection = sections[lastSection].numberOfObjects
            return IndexPath(item: lastItemInSection, section: lastSection)
        } else {
            return IndexPath(item: frc.fetchedObjects?.count ?? 0, section: 0)
        }
    }
    
    public subscript (position: IndexPath) -> T {
        precondition((startIndex ..< endIndex).contains(position), "out of bounds")
        return frc.object(at: position)
    }
    
    subscript (position: (item: Int, section: Int)) -> T {
        let index = IndexPath(item: position.item, section: position.section)
        precondition((startIndex ..< endIndex).contains(index), "out of bounds")
        return frc.object(at: index)
    }
    
    
    public func index(after i: IndexPath) -> IndexPath {
        // Get the overall index of the item in all fetched objects
        // Then get the item immediately following it
        // Then get that item's index path
        
        // This should deal with the situation when the next object
        // is in a different section, so we can't just increment `item`
        
        let currentObject = frc.object(at: i)
        let index = frc.fetchedObjects!.index(of: currentObject)! as Int
        let nextIndex = index + 1
        
        if nextIndex < frc.fetchedObjects!.count {
            let nextObject = frc.fetchedObjects?[nextIndex]
            return frc.indexPath(forObject: nextObject!)!
        }
        
        return IndexPath(item: i.item + 1, section: i.section)
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updates = []
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            updates.append(.insertSection(at: sectionIndex))
        case .delete:
            updates.append(.deleteSection(at: sectionIndex))
        default:
            break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let indexPath = indexPath, let newIndexPath = newIndexPath, indexPath != newIndexPath {
            // To fix bug around moving objects between sections?
            return updates.append(.move(from: indexPath, to: newIndexPath))
        }
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.insert(at: indexPath))
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.update(at: indexPath, with: self[indexPath]))
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updates.append(.move(from: indexPath, to: newIndexPath))
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.delete(at: indexPath))
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.updateSections()
        onChange(Result { self }, updates)
    }
    
    /// Create a static array from the currently fetched objects.
    /// These objects may still set to isDeleted, but the size of the array will not change.
    ///
    /// - Returns: An array of managedObjects.
    func snapshot() -> [T] {
        return Array(self)
    }
    
    /// Represents a section in the fetched data.
    public struct Section<T> {
        var name: String
        var indexTitle: String?
        var numberOfObjects: Int
    }
}

