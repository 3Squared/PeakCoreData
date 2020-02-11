//
//  CoreDataOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataOperation: ConcurrentOperation {
        
    private var operationContext: NSManagedObjectContext!
    private var willSaveContext: (NSManagedObjectContext) -> Void = { _ in }
    private var didSaveContext: (NSManagedObjectContext, Error?) -> Void = { (_, _) in }
    
    private let persistentContainer: NSPersistentContainer
    private let mergePolicyType: NSMergePolicyType
    
    public init(persistentContainer: NSPersistentContainer, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.persistentContainer = persistentContainer
        self.mergePolicyType = mergePolicyType
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
        fatalError("Subclasses must implement \(#function)")
    }
    
    // MARK: - Public Methods
    
    /// Saves the operation context if needed.
    /// - Note: This must be called on the operation context's thread.
    open func saveOperationContext() throws {
        guard !isCancelled else { return finish() }
        guard operationContext.hasChanges else { return }
        
        willSave(context: operationContext)
        
        do {
            try operationContext.save()
            didSave(context: operationContext, saveError: nil)
        } catch {
            didSave(context: operationContext, saveError: error)
            throw error
        }
    }
    
    @discardableResult
    public func calculateChangeset(with existingChangeset: Changeset? = nil) throws -> Changeset {
        return try operationContext.calculateChangeset(with: existingChangeset)
    }
    
    public func willSave(context: NSManagedObjectContext) {
        willSaveContext(context)
    }
    
    public func didSave(context: NSManagedObjectContext, saveError: Error?) {
        didSaveContext(context, saveError)
    }
    
    /// Add a block to be called just before a save begins executing.
    /// - Parameter block: Contains the operation context.
    public func addWillSaveContextBlock(block: @escaping (NSManagedObjectContext) -> Void) {
        let existing = willSaveContext
        willSaveContext = { context in
            existing(context)
            block(context)
        }
    }
    
    /// Add a block to be called just after a save has executed
    /// - Parameter block: Contains the operation context and any error returned from the save.
    public func addDidSaveContextBlock(block: @escaping (NSManagedObjectContext, Error?) -> Void) {
        let existing = didSaveContext
        didSaveContext = { context, error in
            existing(context, error)
            block(context, error)
        }
    }
}
