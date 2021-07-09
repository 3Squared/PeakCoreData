//
//  CollectionViewUpdatable.swift
//  PeakCoreData-iOS
//
//  Created by Zack Brown on 02/07/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData
import UIKit

public protocol CollectionViewUpdatable: AnyObject {
    associatedtype Object: NSManagedObject
    associatedtype Cell: UICollectionViewCell
    func configure(_ cell: Cell, with object: Object)
}

extension CollectionViewUpdatable {
    
    public func process(updates: [FetchedUpdate<Object>],
                        for collectionView: UICollectionView,
                        completion: ((Bool) -> Void)? = nil) {
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
