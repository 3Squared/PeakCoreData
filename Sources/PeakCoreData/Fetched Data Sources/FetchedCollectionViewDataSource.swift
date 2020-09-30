//
//  FetchedCollectionViewDataSource.swift
//  PeakCoreData
//
//  Created by David Yates on 07/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData

public protocol FetchedCollectionViewDataSourceDelegate: CollectionViewUpdatable, HasEmptyView {
    func reuseIdentifier(forCellAt indexPath: IndexPath) -> String
    //Optional
    associatedtype Header: UICollectionReusableView
    associatedtype Footer: UICollectionReusableView
    func reuseIdentifier(forHeaderAt indexPath: IndexPath) -> String?
    func reuseIdentifier(forFooterAt indexPath: IndexPath) -> String?
    func configureHeader(_ header: Header, at indexPath: IndexPath)
    func configureFooter(_ footer: Footer, at indexPath: IndexPath)
    func canMoveItem(at indexPath: IndexPath) -> Bool
    func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

public extension FetchedCollectionViewDataSourceDelegate {
    func reuseIdentifier(forHeaderAt indexPath: IndexPath) -> String? { return nil }
    func reuseIdentifier(forFooterAt indexPath: IndexPath) -> String? { return nil }
    func configureHeader(_ header: UICollectionReusableView, at indexPath: IndexPath) { }
    func configureFooter(_ footer: UICollectionReusableView, at indexPath: IndexPath) { }
    func canMoveItem(at indexPath: IndexPath) -> Bool { return false }
    func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
}

public class FetchedCollectionViewDataSource<Delegate: FetchedCollectionViewDataSourceDelegate>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    public typealias Object = Delegate.Object
    public typealias Cell = Delegate.Cell
    public typealias Header = Delegate.Header
    public typealias Footer = Delegate.Footer

    private let collectionView: UICollectionView
    private let dataProvider: FetchedDataProvider<FetchedCollectionViewDataSource>
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
    
    public required init(collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.collectionView = collectionView
        self.delegate = delegate
        self.dataProvider = FetchedDataProvider(fetchedResultsController: fetchedResultsController)
        super.init()
        collectionView.dataSource = self
        dataProvider.delegate = self
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
    
    public func performFetch() {
        dataProvider.performFetch()
    }
    
    public func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return dataProvider.section(forSectionIndexTitle: title, at: index)
    }
    
    public func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo {
        return dataProvider.sectionInfo(forSection: section)
    }
    
    public func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> Void) {
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
        let reuseIdentifier = delegate.reuseIdentifier(forCellAt: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        delegate.configure(cell, with: object(at: indexPath))
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let reuseIdentifier = delegate.reuseIdentifier(forHeaderAt: indexPath) else {
                fatalError("Missing reuse identifier for header at \(indexPath)")
            }
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath) as? Header else {
                fatalError("Unexpected header type at \(indexPath)")
            }
            delegate.configureHeader(header, at: indexPath)
            return header
        case UICollectionView.elementKindSectionFooter:
            guard let reuseIdentifier = delegate.reuseIdentifier(forFooterAt: indexPath) else {
                fatalError("Missing reuse identifier for footer at \(indexPath)")
            }
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath) as? Footer else {
                fatalError("Unexpected footer type at \(indexPath)")
            }
            delegate.configureFooter(footer, at: indexPath)
            return footer
        default:
            fatalError("Unexpected supplementary element of kind \(kind)")
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return delegate.canMoveItem(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        delegate.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }
}

extension FetchedCollectionViewDataSource: FetchedDataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [FetchedUpdate<Object>]?) {
        guard let updates = updates, animateUpdates, collectionView.window != nil else {
            collectionView.reloadData()
            showEmptyViewIfNeeded()
            onDidChangeContent?()
            return
        }
        
        delegate.process(updates: updates, for: collectionView) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.showEmptyViewIfNeeded()
            strongSelf.onDidChangeContent?()
        }
    }
}
