//
//  CoreDataOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataOperation<Output>: ConcurrentOperation, ProducesResult {
    
    public let persistentContainer: NSPersistentContainer
    public let cache: ManagedObjectCache?
    public let mergePolicyType: NSMergePolicyType
    
    public var output: Result<Output, Error> = Result { throw ResultError.noResult }
    
    private(set) public var operationContext: NSManagedObjectContext!
    private(set) public var inserted: Set<NSManagedObjectID> = []
    private(set) public var updated: Set<NSManagedObjectID> = []
    private(set) public var deleted: Set<NSManagedObjectID> = []

    public init(persistentContainer: NSPersistentContainer,
                cache: ManagedObjectCache? = nil,
                mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.persistentContainer = persistentContainer
        self.mergePolicyType = mergePolicyType
        self.cache = cache
        super.init()
    }
    
    // MARK: - ConcurrentOperation Overrides

    open override func execute() {
        persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            context.name = "PeakCoreData.CoreDataOperation.OperationContext"
            context.mergePolicy = NSMergePolicy(merge: self.mergePolicyType)
            
            self.operationContext = context
            self.performWork(in: context)
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
