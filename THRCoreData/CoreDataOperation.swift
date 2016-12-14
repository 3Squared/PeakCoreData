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
    
    fileprivate let coreDataManager: CoreDataManager
    fileprivate var childContext: NSManagedObjectContext!
    fileprivate(set) public var error: Error?

    public init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - ConcurrentOperation Overrides

    open override func run() {
        childContext = coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
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

    public func completeAndSave() {
        guard !isCancelled else {
            finish()
            return
        }
        
        coreDataManager.save(context: childContext) {
            [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.operationResult = result
            strongSelf.finish()
        }
    }
}
