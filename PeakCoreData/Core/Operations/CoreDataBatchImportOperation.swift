//
//  CoreDataBatchImportOperation.swift
//  PeakCoreData
//
//  Created by Ben Walker on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataBatchImportOperation<Intermediate>: CoreDataOperation, ConsumesResult, ProducesResult where Intermediate: ManagedObjectUpdatable & UniqueIdentifiable {
    
    typealias ManagedObject = Intermediate.ManagedObject
    
    public var input: Result<[Intermediate], Error> = Result { throw ResultError.noResult }
    public var output: Result<Int, Error> = Result { throw ResultError.noResult }
    
    private let batchSize: Int
    private let cache: ManagedObjectCache?
    private var batches: [[Intermediate]] = []
    private var importedCount: Int = 0
    
    public init(batchSize: Int = 50_000, cache: ManagedObjectCache? = nil, persistentContainer: NSPersistentContainer, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.batchSize = batchSize
        self.cache = cache
        super.init(persistentContainer: persistentContainer, mergePolicyType: mergePolicyType)
    }

    open override func performWork(in context: NSManagedObjectContext) {
        do {
            let intermediates = try input.get()
            
            let count = intermediates.count * ((Intermediate.hasProperties && Intermediate.hasRelationships) ? 2 : 1)
            let importProgress = Progress(totalUnitCount: Int64(count))
            progress.addChild(importProgress, withPendingUnitCount: progress.totalUnitCount)
            
            batches = intermediates.chunked(into: batchSize)
            importNextBatch(in: context, importProgress: importProgress)
        } catch {
            output = Result { throw error }
            finish()
        }
    }
    
    func importNextBatch(in context: NSManagedObjectContext, importProgress: Progress) {
        guard !isCancelled else { return finish() }
        guard let intermediates = batches.first else {
            output = .success(importedCount)
            return finish()
        }
        
        batches.removeFirst()
        
        if let updateProperties = Intermediate.updateProperties {
            ManagedObject.insertOrUpdate(intermediates: intermediates, in: context, with: cache) { intermediate, managedObject in
                updateProperties(intermediate, managedObject)
                importProgress.completedUnitCount += 1
            }
        }
        
        if let updateRelationships = Intermediate.updateRelationships {
            ManagedObject.insertOrUpdate(intermediates: intermediates, in: context, with: cache) { intermediate, managedObject in
                updateRelationships(intermediate, managedObject, context, self.cache)
                importProgress.completedUnitCount += 1
            }
        }
        
        do {
            try saveOperationContext()
            importedCount += intermediates.count
            importNextBatch(in: context, importProgress: importProgress)
        } catch {
            // If a single batch fails, we end the import.
            output = .failure(error)
            finish()
        }
    }
}

extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
