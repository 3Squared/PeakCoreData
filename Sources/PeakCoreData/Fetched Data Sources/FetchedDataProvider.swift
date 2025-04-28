
//
//  FetchedDataProvider.swift
//  PeakCoreData
//
//  Created by David Yates on 08/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

#if canImport(UIKit)

import UIKit
import CoreData

public enum FetchedUpdate<Object> {
    case insert(IndexPath)
    case update(IndexPath, Object)
    case move(IndexPath, IndexPath)
    case delete(IndexPath)
    case insertSection(at: Int)
    case deleteSection(at: Int)
}

public protocol HasEmptyView: AnyObject {
    var emptyView: UIView? { get }
}

public extension HasEmptyView {
    var emptyView: UIView? { nil }
}

protocol FetchedDataProviderDelegate: AnyObject {
    associatedtype Object: NSManagedObject
    func dataProviderDidUpdate(updates: [FetchedUpdate<Object>]?)
}

class FetchedDataProvider<Delegate: FetchedDataProviderDelegate>: NSObject, NSFetchedResultsControllerDelegate {
    
    typealias Object = Delegate.Object
    
    var cacheName: String? {
        fetchedResultsController.cacheName
    }
    
    var fetchedObjectsCount: Int {
        var sum = 0
        fetchedResultsController.sections?.forEach { (sectionInfo) in
            sum += sectionInfo.numberOfObjects
        }
        return sum
    }
    
    var fetchedObjects: [Object] {
        fetchedResultsController.fetchedObjects ?? []
    }
    
    var isEmpty: Bool {
        fetchedObjectsCount == 0
    }
    
    var sections: [NSFetchedResultsSectionInfo] {
        fetchedResultsController.sections ?? []
    }

    var numberOfSections: Int {
        sections.count
    }
    
    var sectionIndexTitles: [String] {
        fetchedResultsController.sectionIndexTitles
    }
    
    var sectionNameKeyPath: String? {
        fetchedResultsController.sectionNameKeyPath
    }
    
    private let fetchedResultsController: NSFetchedResultsController<Object>
    private var updates: [FetchedUpdate<Object>] = []
    
    weak var delegate: Delegate!

    init(fetchedResultsController: NSFetchedResultsController<Object>) {
        self.fetchedResultsController = fetchedResultsController
        super.init()
        fetchedResultsController.delegate = self
    }
    
    func performFetch() {
        fetchedResultsController.managedObjectContext.performAndWait {
            do { try fetchedResultsController.performFetch() } catch { fatalError("Fetch request failed") }
            delegate.dataProviderDidUpdate(updates: nil)
        }
    }
    
    func indexPath(forObject object: Object) -> IndexPath? {
        fetchedResultsController.indexPath(forObject: object)
    }
    
    func name(in section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        return sectionInfo.name
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func object(at indexPath: IndexPath) -> Object {
        fetchedResultsController.object(at: indexPath)
    }
    
    func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo {
        fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    }
    
    func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> Void) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: cacheName)
        configure(fetchedResultsController.fetchRequest)
        performFetch()
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updates = []
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let object = anObject as? Object else { fatalError("Wrong type of object returned") }
        
        if let indexPath = indexPath, let newIndexPath = newIndexPath, indexPath != newIndexPath {
            updates.append(.update(indexPath, object))
            updates.append(.move(indexPath, newIndexPath))
            return
        }
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { fatalError("Property newIndexPath should not be nil when inserting") }
            updates.append(.insert(newIndexPath))
        case .update:
            guard let indexPath = indexPath else { fatalError("Property indexPath should not be nil when updating") }
            updates.append(.update(indexPath, object))
        case .move:
            guard let indexPath = indexPath else { fatalError("Property indexPath should not be nil when moving") }
            guard let newIndexPath = newIndexPath else { fatalError("Property newIndexPath should not be nil when moving") }
            updates.append(.update(indexPath, object))
            updates.append(.move(indexPath, newIndexPath))
        case .delete:
            guard let indexPath = indexPath else { fatalError("Property indexPath should not be nil when deleting") }
            updates.append(.delete(indexPath))
        @unknown default:
            break
        }
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
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate.dataProviderDidUpdate(updates: updates)
    }
}

#endif
