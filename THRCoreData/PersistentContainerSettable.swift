//
//  CoreDataStackSettable.swift
//  THRCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData

public protocol PersistentContainerSettable: class {
    
    var persistentContainer: PersistentContainer! { get set }
}

public extension PersistentContainerSettable {
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.mainContext
    }
}

protocol NSPersistentContainerSettable: class {
    var persistentContainer: NSPersistentContainer! { get set }
}

extension NSPersistentContainerSettable {
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
