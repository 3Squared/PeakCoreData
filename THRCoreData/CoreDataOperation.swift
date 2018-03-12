//
//  CoreDataOperation.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData
import THROperations
import THRResult

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
        persistentContainer.performBackgroundTask { (context) in
            self.operationContext = context
            self.operationContext.name = "THRCoreData.CoreDataOperation.OperationContext"
            self.operationContext.mergePolicy = NSMergePolicy(merge: self.mergePolicyType)
            self.performWork(in: context)
        }
    }
    
    // MARK: - Methods to be overidden
    
    open func performWork(in context: NSManagedObjectContext) {
        print("\(self) must override `performWork()`.")
        finish()
    }
}

// MARK: - Public Methods

extension CoreDataOperation {
    
    /// Saves the operation context
    /// This will only set the output on failure; otherwise, subclasses are expected to set their own results.
    public func saveOperationContext() {
        guard !isCancelled else { return finish() }
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
    
    /// Save the context, and finish the operation.
    /// This will only set the output on failure; otherwise, subclasses are expected to set their own results.
    public func saveAndFinish() {
        guard !isCancelled else { return finish() }
        saveOperationContext()
        finish()
    }
}
