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
    private var dataProvider: FetchedDataProvider<FetchedCollectionViewDataSource>!
    private weak var delegate: Delegate!
    
    public var animateUpdates: Bool = true
    public var onDidChangeContent: (() -> Void)?
    
    public var cacheName: String? {
        return dataProvider.cacheName
    }
    
    public var fetchedObjectsCount: Int {
        return dataProvider.fetchedObjectsCount
    }
    
    public var isEmpty: Bool {
        return dataProvider.isEmpty
    }
    
    public var numberOfSections: Int {
        return dataProvider.numberOfSections
    }
    
    public var sectionIndexTitles: [String] {
        return dataProvider.sectionIndexTitles
    }
    
    public var sectionNameKeyPath: String? {
        return dataProvider.sectionNameKeyPath
    }
    
    public required init(collectionView: UICollectionView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.collectionView = collectionView
        self.cellIdentifier = cellIdentifier
        self.delegate = delegate
        super.init()
        collectionView.dataSource = self
        dataProvider = FetchedDataProvider(fetchedResultsController: fetchedResultsController, delegate: self)
        showEmptyViewIfNeeded()
    }
    
    public func indexPath(forObject object: Object) -> IndexPath? {
        return dataProvider.indexPath(forObject: object)
    }
    
    public func name(in section: Int) -> String? {
        return dataProvider.name(in: section)
    }
    
    public func numberOfItems(in section: Int) -> Int {
        return dataProvider.numberOfItems(in: section)
    }
    
    public func object(at indexPath: IndexPath) -> Object {
        return dataProvider.object(at: indexPath)
    }
    
    public func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return dataProvider.section(forSectionIndexTitle: title, at: index)
    }
    
    public func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo {
        return dataProvider.sectionInfo(forSection: section)
    }
    
    public func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> ()) {
        dataProvider.reconfigureFetchRequest(configure)
    }
    
    public func showEmptyViewIfNeeded() {
        if isEmpty, let emptyView = delegate.emptyView {
            collectionView.backgroundView = emptyView
        } else {
            collectionView.backgroundView = nil
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
}

extension FetchedCollectionViewDataSource: FetchedDataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [FetchedUpdate<Delegate.Object>]?) {
        guard let updates = updates, animateUpdates, collectionView.window != nil else {
            collectionView.reloadData()
            showEmptyViewIfNeeded()
            onDidChangeContent?()
            return
        }
        
        let batchUpdates: () -> Void = {
            updates.forEach { (update) in
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

