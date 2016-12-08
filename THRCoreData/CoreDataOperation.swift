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

// Slightly experimental version of our core data operation that uses child context.
// This means changes are saved up the chain rather than being merged in to the main context.

open class CoreDataOperation: ConcurrentOperation<Bool> {
    
    fileprivate let targetContext: NSManagedObjectContext
    fileprivate var childContext: NSManagedObjectContext!
    fileprivate(set) public var error: Error?

    public init(targetContext: NSManagedObjectContext) {
        self.targetContext = targetContext
    }
    
    // MARK: - ConcurrentOperation Overrides

    open override func run() {
        childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = targetContext
        childContext.performAndWait {
            self.performWork(inContext: self.childContext)
        }
    }
}

// MARK: - Public Methods

extension CoreDataOperation {
    
    open func performWork(inContext context: NSManagedObjectContext) {
        print("\(self) must override `performWork()`.")
        finish()
    }
    
    public func completeAndSave() {
        guard !isCancelled, childContext.hasChanges else {
            operationResult = Result { false }
            return finish()
        }
        
        do {
            try childContext.save()
            self.save(parentContext: childContext.parent, completion: { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.operationResult = Result {
                    if let contextError = error {
                        throw contextError
                    } else {
                        return true
                    }
                }
            })
        } catch {
            print("Error saving private context: \(error.localizedDescription)")
            operationResult = Result { throw error }
            return finish()
        }
    }
}

// MARK: - Private Methods

extension CoreDataOperation {
    
    fileprivate func save(parentContext: NSManagedObjectContext?, completion: @escaping (Error?) -> ()) {
        guard let parentContext = parentContext, !isCancelled else {
            return completion(nil)
        }
        parentContext.perform {
            do {
                try parentContext.save()
                self.save(parentContext: parentContext.parent, completion: completion)
            } catch {
                print("Error saving private context: \(error.localizedDescription)")
                completion(error)
            }
        }
    }
}
