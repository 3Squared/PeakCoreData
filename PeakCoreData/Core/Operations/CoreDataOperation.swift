//
//  CoreDataOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation
import PeakResult

open class CoreDataOperation<Output>: ConcurrentOperation, ProducesResult {
    private let persistentContainer: NSPersistentContainer
    private let mergePolicyType: NSMergePolicyType
    private var operationContext: NSManagedObjectContext!
    
    var inserted: Set<NSManagedObjectID> = []
    var updated: Set<NSManagedObjectID> = []
    var deleted: Set<NSManagedObjectID> = []
        
    public var output: Result<Output> = Result { throw ResultError.noResult }

    public init(with persistentContainer: NSPersistentContainer, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.persistentContainer = persistentContainer
        self.mergePolicyType = mergePolicyType
    }
    
    // MARK: - ConcurrentOperation Overrides

    open override func execute() {
        persistentContainer.performBackgroundTask { [weak self] context in
            guard let strongSelf = self else { return }
            strongSelf.operationContext = context
            strongSelf.operationContext.name = "PeakCoreData.CoreDataOperation.OperationContext"
            strongSelf.operationContext.mergePolicy = NSMergePolicy(merge: strongSelf.mergePolicyType)
            strongSelf.performWork(in: context)
        }
    }
    
    // MARK: - Methods to be overidden
    
    open func performWork(in context: NSManagedObjectContext) {
        print("\(self) must override `performWork()`.")
        finish()
    }
    
    // MARK: - Public Methods
    
    /// Saves the operation context
    /// This will only set the output on failure; otherwise, subclasses are expected to set their own results.
    open func saveOperationContext() {
        guard !isCancelled else { return finish() }
        
        operationContext.performAndWait {
            guard operationContext.hasChanges else { return }
            
            do {
                try operationContext.obtainPermanentIDs(for: Array(operationContext.insertedObjects))
                deleted = deleted.union(operationContext.deletedObjects.map { $0.objectID })
                inserted = inserted.union(operationContext.insertedObjects.map { $0.objectID }).subtracting(deleted)
                updated = updated.union(operationContext.updatedObjects.map { $0.objectID }).subtracting(deleted)
                try operationContext.save()
            } catch {
                print("Error saving context \(operationContext.name ?? ""): \(error)")
                output = Result { throw error }
            }
        }
    }
    
    /// Save the context, and finish the operation.
    /// This will only set the output on failure; otherwise, subclasses are expected to set their own results.
    open func saveAndFinish() {
        guard !isCancelled else { return finish() }
        
        saveOperationContext()
        finish()
    }
}
