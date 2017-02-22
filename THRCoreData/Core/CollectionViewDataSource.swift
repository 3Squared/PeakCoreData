//
//  CollectionViewDataSource.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit

public class CollectionViewDataSource<Delegate: DataSourceDelegate, Data: DataProvider>: NSObject, UICollectionViewDataSource where Delegate.Object == Data.Object {
    
    private let collectionView: UICollectionView
    private let dataProvider: Data
    private weak var delegate: Delegate!
    
    required public init(collectionView: UICollectionView, dataProvider: Data, delegate: Delegate) {
        self.collectionView = collectionView
        self.dataProvider = dataProvider
        self.delegate = delegate
        super.init()
        collectionView.dataSource = self
        collectionView.reloadData()
        showEmptyViewIfNeeded()
    }
    
    public var selectedObject: Data.Object? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        return dataProvider.object(at: indexPath)
    }
    
    public func processUpdates(updates: [DataProviderUpdate<Data.Object>]?) {
        guard let updates = updates, collectionView.window != nil else {
            collectionView.reloadData()
            showEmptyViewIfNeeded()
            return
        }
        self.collectionView.performBatchUpdates({
            for update in updates {
                switch update {
                case .insert(let indexPath):
                    self.collectionView.insertItems(at: [indexPath])
                case .update(let indexPath, let object):
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? Delegate.Cell else { break }
                    self.delegate.configure(cell: cell, forObject: object)
                case .move(let fromIndexPath, let toIndexPath):
                    self.collectionView.deleteItems(at: [fromIndexPath])
                    self.collectionView.insertItems(at: [toIndexPath])
                case .delete(let indexPath):
                    self.collectionView.deleteItems(at: [indexPath])
                case .deleteSection(let section):
                    self.collectionView.deleteSections(IndexSet(integer: section))
                case .insertSection(let section):
                    self.collectionView.insertSections(IndexSet(integer: section))
                }
            }
        }, completion: { success in
            self.showEmptyViewIfNeeded()
        })
    }
    
    public func showEmptyViewIfNeeded() {
        if dataProvider.isEmpty, let emptyView = delegate.emptyView() {
            collectionView.backgroundView = emptyView
        } else {
            let view = UIView()
            view.backgroundColor = collectionView.backgroundColor
            collectionView.backgroundView = view
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataProvider.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider.numberOfItems(in: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object = dataProvider.object(at: indexPath)
        let identifier =  delegate.cellIdentifier(forObject: object)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Delegate.Cell else { fatalError("Unexpected cell type at \(indexPath)") }
        delegate.configure(cell: cell, forObject: object)
        return cell as! UICollectionViewCell
    }
}
