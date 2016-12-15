//
//  OperationTests.swift
//  THRCoreData
//
//  Created by David Yates on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable
import THRCoreData

class OperationTests: CoreDataTests {
    
    var operationQueue: OperationQueue {
        let queue = OperationQueue()
        return queue
    }
    
    func testAddOneOperation() {
        let expectedCount = 100
        let id = UUID().uuidString
        var previousOperation: AddOneOperation? = nil
        
        let finishExpectation = expectation(description: #function)

        for _ in 0..<expectedCount {
            let operation = AddOneOperation(coreDataManager: coreDataManager, uniqueKeyValue: id)
            if let previousOperation = previousOperation {
                operation.addDependency(previousOperation)
            }
            operationQueue.addOperation(operation)
            previousOperation = operation
        }
        
        var count = 0
        let finishOperation = BlockOperation {
            // Check that all the changes have made their way to the main context
            let objectToUpdate = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: self.coreDataManager.mainContext)
            count = Int(objectToUpdate.count)
            finishExpectation.fulfill()
        }
        
        finishOperation.addDependency(previousOperation!)
        operationQueue.addOperation(finishOperation)
        
        // THEN: then the main and background contexts are saved and the completion handler is called
        waitForExpectations(timeout: defaultTimeout, handler: { error in
            XCTAssertEqual(count, expectedCount)
        })
    }
    
    func testBatchImportOperation() {
        let numberOfInserts = 5
        let numberOfItems = 100
        var previousOperation: BatchImportOperation? = nil

        let finishExpectation = expectation(description: #function)

        for _ in 0..<numberOfInserts {
            let operation = BatchImportOperation(coreDataManager: coreDataManager, intermediateItemCount: numberOfItems)
            if let previousOperation = previousOperation {
                operation.addDependency(previousOperation)
            }
            operationQueue.addOperation(operation)
            previousOperation = operation
        }
        
        var count = 0
        let finishOperation = BlockOperation {
            // Check that all the changes have made their way to the main context
            count = TestEntity.count(inContext: self.coreDataManager.mainContext)
            finishExpectation.fulfill()
        }
        
        finishOperation.addDependency(previousOperation!)
        operationQueue.addOperation(finishOperation)
        
        // THEN: then the main and background contexts are saved and the completion handler is called
        waitForExpectations(timeout: defaultTimeout, handler: { error in
            XCTAssertEqual(count, (numberOfInserts * numberOfItems))
        })
    }
}

class AddOneOperation: CoreDataOperation {
    
    let uniqueKeyValue: String
    
    init(coreDataManager: CoreDataManager, uniqueKeyValue: String) {
        self.uniqueKeyValue = uniqueKeyValue
        super.init(coreDataManager: coreDataManager)
    }
    
    override func performWork(inContext context: NSManagedObjectContext) {
        let objectToUpdate = TestEntity.fetchOrInsertObject(withUniqueKeyValue: uniqueKeyValue, inContext: context)
        objectToUpdate.count += 1
        completeAndSave()
    }
}

class BatchImportOperation: CoreDataOperation {
    
    let intermediateItemCount: Int
    
    init(coreDataManager: CoreDataManager, intermediateItemCount: Int) {
        self.intermediateItemCount = intermediateItemCount
        super.init(coreDataManager: coreDataManager)
    }
    
    override func performWork(inContext context: NSManagedObjectContext) {
        let intermediateItems = CoreDataTests.createTestIntermediateObjects(number: intermediateItemCount, inContext: context)
        TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: context) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
        }
        completeAndSave()
    }
}
