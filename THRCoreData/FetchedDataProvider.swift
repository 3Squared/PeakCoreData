
//
//  FetchedDataProvider.swift
//  THRCoreData
//
//  Created by David Yates on 08/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData

enum FetchedUpdate<Object> {
    case insert(IndexPath)
    case update(IndexPath, Object)
    case move(IndexPath, IndexPath)
    case delete(IndexPath)
    case insertSection(at: Int)
    case deleteSection(at: Int)
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
    
    var isEmpty: Bool {
        return fetchedObjectsCount == 0
    }
    
    var numberOfSections: Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    var sectionIndexTitles: [String] {
        return fetchedResultsController.sectionIndexTitles
    }
    
    var sectionNameKeyPath: String? {
        return fetchedResultsController.sectionNameKeyPath
    }
    
    private let fetchedResultsController: NSFetchedResultsController<Object>
    private weak var delegate: Delegate!
    private var updates: [FetchedUpdate<Object>] = []
    
    init(fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        do { try fetchedResultsController.performFetch() } catch { fatalError("Fetch request failed") }
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
        do { try fetchedResultsController.performFetch() } catch { fatalError("fetch request failed") }
        delegate.dataProviderDidUpdate(updates: nil)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updates = []
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if let indexPath = indexPath, let newIndexPath = newIndexPath {
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
