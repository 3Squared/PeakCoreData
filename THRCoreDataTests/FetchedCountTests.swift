//
//  FetchedCountTests.swift
//  THRCoreDataTests
//
//  Created by David Yates on 16/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import THRCoreData

class FetchedCountTests: CoreDataTests {
    
    let insertNumber = 10000
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchedCountOnChangeBlock() {
        let expect = expectation(description: "")
        
        let fetchedCount = FetchedCount<TestEntity>(predicate: nil, context: viewContext)
        fetchedCount.onChange = { count in
            XCTAssertEqual(count, self.insertNumber)
            expect.fulfill()
        }
        
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testFetchedCountOnChangeBlockWithAnother() {
        let expect = expectation(description: "")
        
        let fetchedCount = FetchedCount<TestEntity>(predicate: nil, context: viewContext)
        fetchedCount.onChange = { count in
            XCTAssertEqual(count, self.insertNumber)
            expect.fulfill()
        }
        
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        CoreDataTests.createAnotherEntityManagedObjects(in: viewContext, count: insertNumber)
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdatedFetchedCountOnChangeBlock() {
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        let expect = expectation(description: "")
        
        let fetchedCount = FetchedCount<TestEntity>(predicate: nil, context: viewContext)
        XCTAssertEqual(fetchedCount.count, insertNumber)
        fetchedCount.onChange = { count in
            XCTAssertEqual(count, self.insertNumber * 2)
            expect.fulfill()
        }
        
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testFetchedCountCount() {
        let expect = expectation(description: "")

        let fetchedCount = FetchedCount<TestEntity>(predicate: nil, context: viewContext)
        XCTAssertEqual(fetchedCount.count, 0)
        
        fetchedCount.onChange = { count in
            XCTAssertEqual(fetchedCount.count, self.insertNumber)
            expect.fulfill()
        }
        
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testFetchedCountWithPredicate() {
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        let expect = expectation(description: "")

        let predicate = NSPredicate(format: "%K BEGINSWITH %@", argumentArray: [#keyPath(TestEntity.uniqueID), "A"])
        let count1 = TestEntity.count(in: viewContext, matching: predicate)

        let fetchedCount = FetchedCount<TestEntity>(predicate: predicate, context: viewContext)
        XCTAssertEqual(fetchedCount.count, count1)
        
        var observedCount: Int = 0
        fetchedCount.onChange = { count in
            observedCount = count
            expect.fulfill()
        }
        
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        let count2 = TestEntity.count(in: viewContext, matching: predicate)

        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(observedCount, count2)
    }
}
