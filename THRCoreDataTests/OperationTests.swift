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
import THRResult

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
            let operation = AddOneOperation(persistentContainer: persistentContainer, uniqueKeyValue: id)
            if let previousOperation = previousOperation {
                operation.addDependency(previousOperation)
            }
            operationQueue.addOperation(operation)
            previousOperation = operation
        }
        
        var count = 0
        let finishOperation = BlockOperation {
            // Check that all the changes have made their way to the main context
            let objectToUpdate = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: self.mainContext)
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
        var previousOperation: CoreDataImportOperation<TestEntity>? = nil

        let finishExpectation = expectation(description: #function)

        for _ in 0..<numberOfInserts {
        
            // Create intermediate objects
            let input = CoreDataTests.createTestIntermediateObjects(number: numberOfItems, inContext: persistentContainer.mainContext)
            try! persistentContainer.mainContext.save()
            
            
            // Create import operation with intermediates as input
            let operation = CoreDataImportOperation<TestEntity>(persistentContainer: persistentContainer)
            operation.input = Result { input }
            
            if let previousOperation = previousOperation {
                operation.addDependency(previousOperation)
            }
            
            operationQueue.addOperation(operation)
            previousOperation = operation
        }
        
        previousOperation?.addResultBlock { result in
            let count = TestEntity.count(inContext: self.mainContext)
            XCTAssertEqual(count, (numberOfInserts * numberOfItems))
            finishExpectation.fulfill()
        }
        
        // THEN: then the main and background contexts are saved and the completion handler is called
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testBatchImportOutcomeNumbersAreCorrect() {
        let numberOfItems = 100
        let finishExpectation = expectation(description: #function)

        let input = CoreDataTests.createTestIntermediateObjects(number: numberOfItems, inContext: persistentContainer.mainContext)
        try! persistentContainer.mainContext.save()
        
        // Create import operation with intermediates as input
        let operation = CoreDataImportOperation<TestEntity>(persistentContainer: persistentContainer)
        operation.input = Result { input }
        
        operation.addResultBlock { result in
            let outcome = try! result.resolve()
            outcome.inserted.forEach {
                XCTAssertFalse($0.isTemporaryID)
            }
            outcome.updated.forEach {
                XCTAssertFalse($0.isTemporaryID)
            }
            XCTAssertEqual(outcome.inserted.count, numberOfItems / 2)
            XCTAssertEqual(outcome.updated.count, numberOfItems / 2)
            XCTAssertEqual(outcome.all.count, numberOfItems)

            finishExpectation.fulfill()
        }
        
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: defaultTimeout)
    }
}

class AddOneOperation: CoreDataOperation<Void> {
    
    let uniqueKeyValue: String

    init(persistentContainer: PersistentContainer, uniqueKeyValue: String) {
        self.uniqueKeyValue = uniqueKeyValue
        super.init(persistentContainer: persistentContainer)
    }
    
    override func performWork(inContext context: NSManagedObjectContext) {
        let objectToUpdate = TestEntity.fetchOrInsertObject(withUniqueKeyValue: uniqueKeyValue, inContext: context)
        objectToUpdate.count += 1
        finishAndSave()
    }
}

