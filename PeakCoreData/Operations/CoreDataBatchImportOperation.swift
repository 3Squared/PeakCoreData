//
//  ImportManyOperation.swift
//  PeakCoreData
//
//  Created by Ben Walker on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import PeakOperation
import PeakResult

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

open class CoreDataBatchImportOperation<Intermediate>: CoreDataChangesetOperation, ConsumesResult where
    Intermediate: ManagedObjectUpdatable & UniqueIdentifiable,
    Intermediate.ManagedObject: ManagedObjectType & UniqueIdentifiable
{
    public var input: Result<[Intermediate]> = Result { throw ResultError.noResult }
    private var batchSize: Int = 1000
    
    typealias ManagedObject = Intermediate.ManagedObject
    
    init(with persistentContainer: NSPersistentContainer, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType, batchSize: Int? = nil) {
        
        if let batchSize = batchSize {
            self.batchSize = batchSize
        }
        
        super.init(with: persistentContainer, mergePolicyType: mergePolicyType)
    }
    
    open override func performWork(in context: NSManagedObjectContext) {
        do {
            let intermediates = try input.resolve()
            
            let chunked = intermediates.chunked(into: batchSize)
            
            chunked.forEach { (tasks: [Intermediate]) in
                ManagedObject.insertOrUpdate(intermediates: intermediates, in: context) { intermediate, managedObject in
                    intermediate.updateProperties(on: managedObject)
                }
                
                ManagedObject.insertOrUpdate(intermediates: intermediates, in: context) { intermediate, managedObject in
                    intermediate.updateRelationships(on: managedObject, in: context)
                }
                
                saveOperationContext()
            }
            
            saveAndFinish()
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}
