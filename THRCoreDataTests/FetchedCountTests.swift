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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchedCountOnChangeBlock() {
        let expect = expectation(description: "")
        
        let fetchedCount = FetchedCount<TestEntity>(predicate: nil, managedObjectContext: viewContext)
        fetchedCount.onChange = { count in
            XCTAssertEqual(count, 100)
            expect.fulfill()
        }
        
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 100)
        try! viewContext.save()
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdatedFetchedCountOnChangeBlock() {
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 100)
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let fetchedCount = FetchedCount<TestEntity>(predicate: nil, managedObjectContext: viewContext)
        XCTAssertEqual(fetchedCount.count, 100)
        fetchedCount.onChange = { count in
            XCTAssertEqual(count, 200)
            expect.fulfill()
        }
        
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 100)
        try! viewContext.save()
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testFetchedCountCount() {
        let fetchedCount = FetchedCount<TestEntity>(predicate: nil, managedObjectContext: viewContext)
        XCTAssertEqual(fetchedCount.count, 0)
        
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 100)
        try! viewContext.save()
        
        XCTAssertEqual(fetchedCount.count, 100)
    }
    
    func testFetchedCountWithPredicate() {
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 1000)
        try! viewContext.save()
        
        let expect = expectation(description: "")

        let predicate = NSPredicate(format: "%K BEGINSWITH %@", argumentArray: [#keyPath(TestEntity.uniqueID), "A"])
        let count1 = TestEntity.count(in: viewContext, matching: predicate)

        let fetchedCount = FetchedCount<TestEntity>(predicate: predicate, managedObjectContext: viewContext)
        XCTAssertEqual(fetchedCount.count, count1)
        
        var observedCount: Int = 0
        fetchedCount.onChange = { count in
            observedCount = count
            expect.fulfill()
        }
        
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 1000)
        try! viewContext.save()
        
        let count2 = TestEntity.count(in: viewContext, matching: predicate)

        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(observedCount, count2)
    }
}
