//
//  FetchedCollectionViewDataSource.swift
//  THRCoreData
//
//  Created by David Yates on 07/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData

public protocol FetchedCollectionViewDataSourceDelegate: class {
    associatedtype Object: NSManagedObject
    associatedtype Cell: UICollectionViewCell
    func configure(_ cell: Cell, with object: Object)
    
    // Optional
    var emptyView: UIView? { get }
}

public extension FetchedCollectionViewDataSourceDelegate {
    
    var emptyView: UIView? { return nil }
}

public class FetchedCollectionViewDataSource<Delegate: FetchedCollectionViewDataSourceDelegate>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    public typealias Object = Delegate.Object
    public typealias Cell = Delegate.Cell
    
    private let collectionView: UICollectionView
    private let cellIdentifier: String
    private let fetchedResultsController: NSFetchedResultsController<Object>
    private weak var delegate: Delegate!
    private var updates: [FetchedUpdate<Object>] = []
    
    public var animateUpdates: Bool = true
    public var onDidChangeContent: (() -> Void)?
    
    public var cacheName: String? {
        return fetchedResultsController.cacheName
    }
    
    public var isEmpty: Bool {
        return numberOfSections == 0 || (numberOfItems(in: 0) == 0)
    }
    
    public var numberOfSections: Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    public var sectionIndexTitles: [String] {
        return fetchedResultsController.sectionIndexTitles
    }
    
    public var sectionNameKeyPath: String? {
        return fetchedResultsController.sectionNameKeyPath
    }
    
    public required init(collectionView: UICollectionView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.collectionView = collectionView
        self.cellIdentifier = cellIdentifier
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    public func indexPath(forObject object: Object) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    public func name(in section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        return sectionInfo.name
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    public func object(at indexPath: IndexPath) -> Object {
        return fetchedResultsController.object(at: indexPath)
    }
    
    public func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    public func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo {
        return fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    }
    
    public func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> ()) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: cacheName)
        configure(fetchedResultsController.fetchRequest)
        do { try fetchedResultsController.performFetch() } catch { fatalError("fetch request failed") }
        collectionView.reloadData()
    }
    
    public func showEmptyViewIfNeeded() {
        if isEmpty, let emptyView = delegate.emptyView {
            collectionView.backgroundView = emptyView
        } else {
            let view = UIView()
            view.backgroundColor = collectionView.backgroundColor
            collectionView.backgroundView = view
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(in: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? Cell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        delegate.configure(cell, with: object(at: indexPath))
        return cell
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard animateUpdates, collectionView.window != nil else { return }

        updates = []
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard animateUpdates, collectionView.window != nil else { return }
        
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.insert(indexPath))
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
        guard animateUpdates, collectionView.window != nil else { return }

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
        guard animateUpdates, collectionView.window != nil else {
            collectionView.reloadData()
            showEmptyViewIfNeeded()
            onDidChangeContent?()
            return
        }
        
        let batchUpdates: () -> Void = {
            self.updates.forEach { (update) in
                switch update {
                case .insert(let indexPath):
                    self.collectionView.insertItems(at: [indexPath])
                case .update(let indexPath, let object):
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? Cell else { fatalError("Wrong cell type") }
                    self.delegate.configure(cell, with: object)
                case .move(let indexPath, let newIndexPath):
                    self.collectionView.moveItem(at: indexPath, to: newIndexPath)
                case .delete(let indexPath):
                    self.collectionView.deleteItems(at: [indexPath])
                case .deleteSection(let section):
                    self.collectionView.deleteSections(IndexSet(integer: section))
                case .insertSection(let section):
                    self.collectionView.insertSections(IndexSet(integer: section))
                }
            }
        }
        
        collectionView.performBatchUpdates(batchUpdates) { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.showEmptyViewIfNeeded()
            strongSelf.onDidChangeContent?()
        }
    }
}
