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
            let operation = AddOneOperation(uniqueKeyValue: id, persistentContainer: persistentContainer)
            if let previousOperation = previousOperation {
                operation.addDependency(previousOperation)
            }
            operationQueue.addOperation(operation)
            previousOperation = operation
        }
        
        var count = 0
        let finishOperation = BlockOperation {
            // Check that all the changes have made their way to the main context
            let objectToUpdate = TestEntity.fetchOrInsertObject(with: id, in: self.viewContext)
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
    
    func testSingleImportOperation() {
        let numberOfInserts = 5
        let numberOfItems = 1
        var previousOperation: CoreDataSingleImportOperation<TestEntityJSON>? = nil
        let finishExpectation = expectation(description: #function)
        
        for _ in 0..<numberOfInserts {
            
            // Create intermediate objects
            let input = CoreDataTests.createTestIntermediateObjects(number: numberOfItems, inContext: viewContext)
            try! viewContext.save()
            
            // Create import operation with intermediates as input
            let operation = CoreDataSingleImportOperation<TestEntityJSON>(with: persistentContainer)
            operation.input = Result { input.first! }
            
            if let previousOperation = previousOperation {
                operation.addDependency(previousOperation)
            }
            
            operationQueue.addOperation(operation)
            previousOperation = operation
        }
        
        previousOperation?.addResultBlock { result in
            let count = TestEntity.count(in: self.viewContext)
            XCTAssertEqual(count, (numberOfInserts * numberOfItems))
            finishExpectation.fulfill()
        }
        
        // THEN: then the main and background contexts are saved and the completion handler is called
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testBatchImportOperation() {
        let numberOfInserts = 5
        let numberOfItems = 100
        var previousOperation: CoreDataBatchImportOperation<TestEntityJSON>? = nil

        let finishExpectation = expectation(description: #function)

        for _ in 0..<numberOfInserts {
        
            // Create intermediate objects
            let input = CoreDataTests.createTestIntermediateObjects(number: numberOfItems, inContext: viewContext)
            try! viewContext.save()
            
            
            // Create import operation with intermediates as input
            let operation = CoreDataBatchImportOperation<TestEntityJSON>(with: persistentContainer)
            operation.input = Result { input }
            
            if let previousOperation = previousOperation {
                operation.addDependency(previousOperation)
            }
            
            operationQueue.addOperation(operation)
            previousOperation = operation
        }
        
        previousOperation?.addResultBlock { result in
            let count = TestEntity.count(in: self.viewContext)
            XCTAssertEqual(count, (numberOfInserts * numberOfItems))
            finishExpectation.fulfill()
        }
        
        // THEN: then the main and background contexts are saved and the completion handler is called
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testBatchImportOutcomeNumbersAreCorrect() {
        let numberOfItems = 100
        let finishExpectation = expectation(description: #function)

        let input = CoreDataTests.createTestIntermediateObjects(number: numberOfItems, inContext: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()
        
        // Create import operation with intermediates as input
        let operation = CoreDataBatchImportOperation<TestEntityJSON>(with: persistentContainer)
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

    init(uniqueKeyValue: String, persistentContainer: NSPersistentContainer) {
        self.uniqueKeyValue = uniqueKeyValue
        super.init(with: persistentContainer)
    }
    
    override func performWork(in context: NSManagedObjectContext) {
        let objectToUpdate = TestEntity.fetchOrInsertObject(with: uniqueKeyValue, in: context)
        objectToUpdate.count += 1
        saveAndFinish()
    }
}

