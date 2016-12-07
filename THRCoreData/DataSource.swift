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
    
    func cellIdentifier(forObject object: Object) -> String
    func configure(cell: Cell, forObject object: Object)
    func canEditRow(at indexPath: IndexPath) -> Bool
    func shouldShowSectionIndexTitles() -> Bool
}

public extension DataSourceDelegate {
    
    func canEditRow(at indexPath: IndexPath) -> Bool {
        return false
    }
    
    func shouldShowSectionIndexTitles() -> Bool {
        return false
    }
}
