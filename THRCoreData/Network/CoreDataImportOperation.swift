//
//  ImportManyOperation.swift
//  THRCoreData
//
//  Created by Ben Walker on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import THROperations
import THRNetwork
import THRResult

open class CoreDataImportOperation<JSONRepresentation, ManagedObject>: CoreDataOperation, ConsumesResult where
    ManagedObject: NSManagedObject,
    ManagedObject: ManagedObjectType,
    ManagedObject: UniqueIdentifiable,
    ManagedObject: Updatable,
    JSONRepresentation: UniqueIdentifiable,
    JSONRepresentation == ManagedObject.JSONRepresentation
{
    public var input: Result<[JSONRepresentation]> = Result { throw ResultError.noResult }
    
    override open func performWork(inContext context: NSManagedObjectContext) {
        defer { completeAndSave() }
        do {
            let intermediates = try input.resolve()
            ManagedObject.insertOrUpdate(intermediates: intermediates, inContext: context) { intermediate, model in
                model.updateProperties(with: intermediate)
            }
        } catch {
            print(error)
        }
    }
}
