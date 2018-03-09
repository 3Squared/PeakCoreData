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
    
    fileprivate let targetContext: NSManagedObjectContext
    fileprivate let mergePolicyType: NSMergePolicyType
    fileprivate var childContext: NSManagedObjectContext!
    
    public var output: Result<Output> = Result { throw ResultError.noResult }

    public init(with targetContext: NSManagedObjectContext, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) {
        self.targetContext = targetContext
        self.mergePolicyType = mergePolicyType
    }
    
    // MARK: - ConcurrentOperation Overrides

    open override func execute() {
        childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = targetContext
        if let targetContextName = targetContext.name {
            childContext.name = targetContextName + ".child"
        }
        childContext.mergePolicy = NSMergePolicy(merge: mergePolicyType)
        childContext.performAndWait {
            self.performWork(in: self.childContext)
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

    /// Save the context, and finish the operation.
    /// This will only set the output on failure; otherwise, subclasses are expected to set their own results.
    public func finishAndSave() {
        guard !isCancelled else {
            finish()
            return
        }
        
        save(context: childContext) { [weak self] result in
            guard let strongSelf = self else { return }
            if case .failure(let error) = result {
                strongSelf.output = Result { throw error }
            }
            strongSelf.finish()
        }
    }
}

public enum SaveOutcome {
    case saved
    case noChanges
}

public typealias SaveCompletionType = (Result<SaveOutcome>) -> ()

extension CoreDataOperation {
    
    fileprivate func save(context: NSManagedObjectContext, withCompletion completion: SaveCompletionType? = nil) {
        context.perform {
            guard context.hasChanges else {
                completion?(.success(.noChanges))
                return
            }
            do {
                try context.save()
                if let parentContext = context.parent {
                    self.save(context: parentContext, withCompletion: completion)
                } else {
                    completion?(.success(.saved))
                }
            } catch let error as NSError {
                print("Error saving context: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }
}
