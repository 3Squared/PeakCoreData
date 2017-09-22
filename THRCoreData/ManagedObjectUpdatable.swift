//
//  Updatable.swift
//  THRCoreData
//
//  Created by Sam Oakley on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public protocol ManagedObjectUpdatable {
    associatedtype ManagedObject: NSManagedObject
    func updateProperties(on managedObject: ManagedObject)
    func updateRelationships(on managedObject: ManagedObject, withContext context: NSManagedObjectContext)
}
