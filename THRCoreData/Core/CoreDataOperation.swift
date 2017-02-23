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

open class CoreDataOperation<Output>: BaseOperation, ProducesResult {
    
    fileprivate let persistentContainer: PersistentContainer
    fileprivate var childContext: NSManagedObjectContext!
    
    public var output: Result<Output> = Result { throw ResultError.noResult }

    public init(persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    // MARK: - ConcurrentOperation Overrides

    open override func run() {
        childContext = persistentContainer.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        childContext.performAndWait {
            self.performWork(inContext: self.childContext)
        }
    }
    
    // MARK: - Methods to be overidden
    
    open func performWork(inContext context: NSManagedObjectContext) {
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
        
        persistentContainer.save(context: childContext) { [weak self] result in
            guard let strongSelf = self else { return }
            if case .failure(let error) = result {
                strongSelf.output = Result { throw error }
            }
            strongSelf.finish()
        }
    }
}
