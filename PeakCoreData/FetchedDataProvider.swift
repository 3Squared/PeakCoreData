
//
//  FetchedDataProvider.swift
//  PeakCoreData
//
//  Created by David Yates on 08/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

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

public protocol HasEmptyView: class {
    var emptyView: UIView? { get }
}

public extension HasEmptyView {
    var emptyView: UIView? { return nil }
}

public protocol TableViewUpdatable: class {
    associatedtype Object: NSManagedObject
    associatedtype Cell: UITableViewCell
    func configure(_ cell: Cell, with object: Object)
}

public extension TableViewUpdatable {
    
    public func process(updates: [FetchedUpdate<Object>], for tableView: UITableView, with animation: UITableViewRowAnimation = .automatic, completion: ((Bool) -> Void)? = nil) {
        let batchUpdates: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }

            updates.forEach { (update) in
                switch update {
                case .insert(let indexPath):
                    tableView.insertRows(at: [indexPath], with: animation)
                case .update(let indexPath, let object):
                    guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { return }
                    strongSelf.configure(cell, with: object)
                case .move(let indexPath, let newIndexPath):
                    tableView.moveRow(at: indexPath, to: newIndexPath)
                case .delete(let indexPath):
                    tableView.deleteRows(at: [indexPath], with: animation)
                case .deleteSection(let section):
                    tableView.deleteSections(IndexSet(integer: section), with: animation)
                case .insertSection(let section):
                    tableView.insertSections(IndexSet(integer: section), with: animation)
                }
            }
        }
        
        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates(batchUpdates, completion: completion)
        } else {
            tableView.beginUpdates()
            batchUpdates()
            tableView.endUpdates()
            completion?(true)
        }
    }
}

public protocol CollectionViewUpdatable: class {
    associatedtype Object: NSManagedObject
    associatedtype Cell: UICollectionViewCell
    func configure(_ cell: Cell, with object: Object)
}

extension CollectionViewUpdatable {
    
    public func process(updates: [FetchedUpdate<Object>], for collectionView: UICollectionView, completion: ((Bool) -> Void)? = nil) {
        let batchUpdates: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }
            
            updates.forEach { (update) in
                switch update {
                case .insert(let indexPath):
                    collectionView.insertItems(at: [indexPath])
                case .update(let indexPath, let object):
                    guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else { return }
                    strongSelf.configure(cell, with: object)
                case .move(let indexPath, let newIndexPath):
                    collectionView.moveItem(at: indexPath, to: newIndexPath)
                case .delete(let indexPath):
                    collectionView.deleteItems(at: [indexPath])
                case .deleteSection(let section):
                    collectionView.deleteSections(IndexSet(integer: section))
                case .insertSection(let section):
                    collectionView.insertSections(IndexSet(integer: section))
                }
            }
        }
        collectionView.performBatchUpdates(batchUpdates, completion: completion)
    }
}

protocol FetchedDataProviderDelegate: class {
    associatedtype Object: NSManagedObject
    func dataProviderDidUpdate(updates: [FetchedUpdate<Object>]?)
}

class FetchedDataProvider<Delegate: FetchedDataProviderDelegate>: NSObject, NSFetchedResultsControllerDelegate {
    
    typealias Object = Delegate.Object
    
    var cacheName: String? {
        return fetchedResultsController.cacheName
    }
    
    var fetchedObjectsCount: Int {
        var sum = 0
        fetchedResultsController.sections?.forEach { (sectionInfo) in
            sum += sectionInfo.numberOfObjects
        }
        return sum
    }
    
    var fetchedObjects: [Object] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    var isEmpty: Bool {
        return fetchedObjectsCount == 0
    }
    
    var sections: [NSFetchedResultsSectionInfo] {
        return fetchedResultsController.sections ?? []
    }

    var numberOfSections: Int {
        return sections.count
    }
    
    var sectionIndexTitles: [String] {
        return fetchedResultsController.sectionIndexTitles
    }
    
    var sectionNameKeyPath: String? {
        return fetchedResultsController.sectionNameKeyPath
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
        return fetchedResultsController.indexPath(forObject: object)
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
        return fetchedResultsController.object(at: indexPath)
    }
    
    func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo {
        return fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    }
    
    func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> ()) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: cacheName)
        configure(fetchedResultsController.fetchRequest)
        performFetch()
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updates = []
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if let indexPath = indexPath, let newIndexPath = newIndexPath, indexPath != newIndexPath {
            updates.append(.move(indexPath, newIndexPath))
            return
        }
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.insert(newIndexPath))
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.update(indexPath, object(at: indexPath)))
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updates.append(.update(indexPath, object(at: indexPath)))
            updates.append(.move(indexPath, newIndexPath))
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.delete(indexPath))
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
