//
//  DataSource.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData

public protocol DataSourceDelegate: class {
    
    associatedtype Object: NSManagedObject
    associatedtype Cell
    
    // Required
    func cellIdentifier(forObject object: Object) -> String
    func configure(cell: Cell, forObject object: Object)
    
    // Optional (default implementation below)
    func emptyView() -> UIView?
    func canEditRow(at indexPath: IndexPath) -> Bool
    func canMoveRow(at indexPath: IndexPath) -> Bool
    func shouldShowSectionIndexTitles() -> Bool
    func commit(editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    func move(rowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    func titleForHeader(in section: Int) -> String?
    func titleForFooter(in section: Int) -> String?
}

public extension DataSourceDelegate {
    
    func emptyView() -> UIView? {
        return nil
    }
    
    func canEditRow(at indexPath: IndexPath) -> Bool {
        return false
    }
    
    func canMoveRow(at indexPath: IndexPath) -> Bool {
        return false
    }
    
    func shouldShowSectionIndexTitles() -> Bool {
        return false
    }
    
    func commit(editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func move(rowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    func titleForHeader(in section: Int) -> String? {
        return nil
    }
    
    func titleForFooter(in section: Int) -> String? {
        return nil
    }
}
