//
//  CoreDataStackSettable.swift
//  PeakCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData

public protocol PersistentContainerSettable: AnyObject {
    var persistentContainer: NSPersistentContainer! { get set }
}

public extension PersistentContainerSettable {
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveViewContext() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving view context: \(error)")
        }
    }
}
