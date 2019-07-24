//
//  TableViewUpdatable.swift
//  PeakCoreData-iOS
//
//  Created by Zack Brown on 02/07/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData
import UIKit

public protocol TableViewUpdatable: class {
    associatedtype Object: NSManagedObject
    associatedtype Cell: UITableViewCell
    func configure(_ cell: Cell, with object: Object)
}

extension TableViewUpdatable {
    
    public func process(updates: [FetchedUpdate<Object>], for tableView: UITableView, with animation: UITableView.RowAnimation = .automatic, completion: ((Bool) -> Void)? = nil) {
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
        
        if #available(iOS 11.0, tvOS 11.0, *) {
            tableView.performBatchUpdates(batchUpdates, completion: completion)
        } else {
            tableView.beginUpdates()
            batchUpdates()
            tableView.endUpdates()
            completion?(true)
        }
    }
}
