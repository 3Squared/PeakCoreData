//
//  CoreDataFunctions.swift
//  THRCoreData
//
//  Created by David Yates on 14/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import THRResult

public enum SaveOutcome {
    case saved
    case noChanges
}

public typealias SaveCompletionType = (Result<SaveOutcome>) -> ()

/**
 Attempts to commit unsaved changes to registered objects in the specified context.
 
 - warning: This function is performed in the `perform` block on the background context's queue so is asynchronous.
 
 - note: If the context you pass in is a child context, it will automatically propagate changes through the parent context and then to the persistent store.
 
 - parameter context:       The managed object context to save.
 - parameter completion:    The closure to be executed when the save operation completes.
 */
public func save(context: NSManagedObjectContext, withCompletion completion: SaveCompletionType? = nil) {
    context.perform {
        guard context.hasChanges else {
            completion?(.success(.noChanges))
            return
        }
        do {
            try context.save()
            if let parentContext = context.parent {
                save(context: parentContext, withCompletion: completion)
            } else {
                completion?(.success(.saved))
            }
        } catch let error as NSError {
            print("Error saving context: \(error.localizedDescription)")
            completion?(.failure(error))
        }
    }
}
