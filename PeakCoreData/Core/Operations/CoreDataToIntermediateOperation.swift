//
//  CoreDataToIntermediateOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 28/03/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataToIntermediateOperation<Intermediate>: CoreDataOperation, ProducesResult where Intermediate: ManagedObjectInitialisable {
    
    typealias ManagedObject = Intermediate.ManagedObject
    
    public var output: Result<[Intermediate], Error> = Result { throw ResultError.noResult }
    
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
