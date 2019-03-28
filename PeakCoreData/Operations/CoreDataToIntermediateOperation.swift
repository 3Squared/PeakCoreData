//
//  CoreDataToIntermediateOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 28/03/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataToIntermediateOperation<Intermediate>: CoreDataOperation<[Intermediate]> where
    Intermediate: ManagedObjectInitialisable,
    Intermediate.ManagedObject: ManagedObjectType
{
    typealias ManagedObject = Intermediate.ManagedObject
    
    private let predicate: NSPredicate?
    
    public init(with persistentContainer: NSPersistentContainer, matching predicate: NSPredicate? = nil) {
        self.predicate = predicate
        super.init(with: persistentContainer)
    }
    
    open override func performWork(in context: NSManagedObjectContext) {
        let objects = ManagedObject.fetch(in: context) { (request) in
            request.predicate = self.predicate
        }
        output = Result {
            try objects.map(Intermediate.init)
        }
        finish()
    }
}
