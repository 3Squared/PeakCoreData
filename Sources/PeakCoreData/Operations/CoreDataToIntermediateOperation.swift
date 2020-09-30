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
    
    public init(predicate: NSPredicate? = nil, persistentContainer: NSPersistentContainer) {
        self.predicate = predicate
        super.init(persistentContainer: persistentContainer)
    }
    
    open override func performWork(in context: NSManagedObjectContext) {
        let objects = ManagedObject.fetch(in: context) { $0.predicate = self.predicate }
        
        output = Result {
            try objects.map(Intermediate.init)
        }
        
        finish()
    }
}
