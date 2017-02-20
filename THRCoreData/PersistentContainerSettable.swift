//
//  CoreDataStackSettable.swift
//  THRCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData

public protocol PersistentContainerSettable: class {
    
    var coreDataStack: PersistentContainer! { get set }
}

public extension PersistentContainerSettable {
    
    var mainContext: NSManagedObjectContext {
        return coreDataStack.mainContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return coreDataStack.backgroundContext
    }
}
