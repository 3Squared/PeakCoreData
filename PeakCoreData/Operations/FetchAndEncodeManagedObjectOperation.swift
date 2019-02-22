//
//  FetchAndEncodeManagedObjectOperation.swift
//  PeakCoreData
//
//  Created by Ben Walker on 22/02/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import PeakResult

class FetchAndEncodeManagedObjectsOperation<ManagedObject, JSONRepresentation>: CoreDataOperation<[JSONRepresentation]> where
    JSONRepresentation: ManagedObjectInitialisable, JSONRepresentation: Encodable, JSONRepresentation.ManagedObject == ManagedObject,
    ManagedObject: ManagedObjectType
{
    
    private let predicate: NSPredicate
    
    init(matching predicate: NSPredicate, with persistentContainer: NSPersistentContainer) {
        self.predicate = predicate
        super.init(with: persistentContainer)
    }
    
    override func performWork(in context: NSManagedObjectContext) {
        let objects = ManagedObject.fetch(in: context) { request in
            request.predicate = self.predicate
        }
        
        output = Result {
            try objects.compactMap { object in
                try JSONRepresentation(with: object)
            }
        }
        
        finish()
    }
}
