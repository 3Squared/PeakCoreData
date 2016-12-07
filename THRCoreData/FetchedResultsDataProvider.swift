//
//  FetchedResultsDataProvider.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData

public class FetchedResultsDataProvider<Delegate: DataProviderDelegate>: NSObject, NSFetchedResultsControllerDelegate, DataProvider {
    
    public typealias Object = Delegate.Object
    
    private let fetchedResultsController: NSFetchedResultsController<Object>
    private weak var delegate: Delegate!
    private var updates: [DataProviderUpdate<Object>] = []
    
    public init(fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            fatalError("Fetch request failed: \(error.localizedDescription)")
        }
    }
    
    public var allObjects: [Object]? {
        return fetchedResultsController.fetchedObjects
    }
    
    public var numberOfSections: Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    public var sectionNameKeyPath: String? {
        return fetchedResultsController.sectionNameKeyPath
    }
    
    public var sectionIndexTitles: [String] {
        return fetchedResultsController.sectionIndexTitles
    }
    
    public var isEmpty: Bool {
        guard let allObjects = allObjects else { return true }
        return allObjects.isEmpty
    }
    
    public func reconfigureFetchRequest(block: (NSFetchRequest<Object>) -> ()) {
        NSFetchedResultsController<Object>.deleteCache(withName: fetchedResultsController.cacheName)
        block(fetchedResultsController.fetchRequest)
        do {
            try fetchedResultsController.performFetch()
            delegate.dataProviderDidUpdate(updates: nil)
        } catch let error as NSError {
            fatalError("Fetch request failed: \(error.localizedDescription)")
        }
    }
    
    public func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    public func object(at indexPath: IndexPath) -> Object {
        return fetchedResultsController.object(at: indexPath)
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    public func name(in section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        return sectionInfo.name
    }
    
    public func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo {
        return fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
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
        if let indexPath = indexPath, let newIndexPath = newIndexPath {
            // To fix bug around moving objects between sections?
            return updates.append(.move(from: indexPath, to: newIndexPath))
        }
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.insert(at: indexPath))
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.update(at: indexPath, with: object(at: indexPath)))
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
        delegate.dataProviderDidUpdate(updates: updates)
    }
}
