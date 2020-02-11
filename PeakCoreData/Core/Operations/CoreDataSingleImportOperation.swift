//
//  CoreDataSingleImportOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 25/09/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataSingleImportOperation<Intermediate>: CoreDataOperation, ConsumesResult, ProducesResult where Intermediate: ManagedObjectUpdatable & UniqueIdentifiable {
    
    typealias ManagedObject = Intermediate.ManagedObject
    
    public var input: Result<Intermediate, Error> = Result { throw ResultError.noResult }
    public var output: Result<Changeset, Error> = Result { throw ResultError.noResult }
    
    private let cache: ManagedObjectCache?
    
    public init(cache: ManagedObjectCache? = nil, persistentContainer: NSPersistentContainer, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.cache = cache
        super.init(persistentContainer: persistentContainer, mergePolicyType: mergePolicyType)
    }
    
    open override func performWork(in context: NSManagedObjectContext) {
        do {
            let intermediate = try input.get()
            
            ManagedObject.fetchOrInsertObject(with: intermediate.uniqueIDValue, in: context, with: cache) { managedObject in
                Intermediate.updateProperties?(intermediate, managedObject)
                Intermediate.updateRelationships?(intermediate, managedObject, context, self.cache)
            }
            
            do {
                let changeset = try calculateChangeset()
                try saveOperationContext()
                output = .success(changeset)
            } catch {
                output = .failure(error)
            }
            
            finish()
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}
