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
    
    func testCoreDataOperation() {
        
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
            let objectToUpdate = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: self.coreDataManager.mainContext)
            count = Int(objectToUpdate.count)
            finishExpectation.fulfill()
        }
        
        finishOperation.addDependency(previousOperation!)
        operationQueue.addOperation(finishOperation)
        
        // THEN: then the main and background contexts are saved and the completion handler is called
        waitForExpectations(timeout: 1.0, handler: { error in
            XCTAssertEqual(count, expectedCount)
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
