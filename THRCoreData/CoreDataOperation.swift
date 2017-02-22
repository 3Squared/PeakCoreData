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

open class CoreDataOperation: BaseOperation {
    
    fileprivate let persistentContainer: PersistentContainer
    fileprivate var childContext: NSManagedObjectContext!
    
    public var saveError: Error?

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

    public func completeAndSave() {
        guard !isCancelled else {
            finish()
            return
        }
        
        persistentContainer.save(context: childContext) { [weak self] result in
            guard let strongSelf = self else { return }
            if case .failure(let error) = result {
                strongSelf.saveError = error
            }
            strongSelf.finish()
        }
    }
}
