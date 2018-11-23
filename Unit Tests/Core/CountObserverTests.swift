//
//  CountObserverTests.swift
//  PeakCoreDataTests
//
//  Created by David Yates on 23/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

class CountObserverTests: CoreDataTests {
    
    let insertNumber = 1000
    
    func testNotifierCalledOnStartNotifier() {
        let expect = expectation(description: "")
        
        let observer = CountObserver<TestEntity>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, 0)
        
        observer.startObserving() { count in
            XCTAssertEqual(count, 0)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testExistingData() {
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        let expect = expectation(description: "")
        
        let observer = CountObserver<TestEntity>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, insertNumber)
        
        observer.startObserving() { count in
            XCTAssertEqual(count, self.insertNumber)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testCountChanges() {
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        let observer = CountObserver<TestEntity>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, insertNumber)
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        XCTAssertEqual(observer.count, insertNumber*2)
        TestEntity.delete(in: viewContext)
        XCTAssertEqual(observer.count, 0)
    }
    
    func testInsertCallsNotifier() {
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let observer = CountObserver<TestEntity>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, 0)
        
        var counts: [Int] = []
        observer.startObserving() { count in
            counts.append(count)
            expect.fulfill()
        }
        
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)

        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(counts, [0, insertNumber])
    }
    
    func testMultipleInsertsCallsNotifier() {
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let observer = CountObserver<TestEntity>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, 0)
        
        var counts: [Int] = []
        observer.startObserving() { count in
            counts.append(count)
            expect.fulfill()
        }
        
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)

        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(counts, [0, insertNumber*2])
    }
    
    func testDeleteCallsNotifier() {
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let observer = CountObserver<TestEntity>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, insertNumber)
        
        var counts: [Int] = []
        observer.startObserving() { count in
            counts.append(count)
            expect.fulfill()
        }
        
        TestEntity.delete(in: viewContext)
        
        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(counts, [insertNumber, 0])
    }
    
    func testFetchedCountWithPredicate() {
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let predicate = NSPredicate(format: "%K BEGINSWITH %@", argumentArray: [#keyPath(TestEntity.uniqueID), "A"])
        let count1 = TestEntity.count(in: viewContext, matching: predicate)
        
        let observer = CountObserver<TestEntity>(predicate: predicate, context: viewContext)
        XCTAssertEqual(observer.count, count1)
        
        var counts: [Int] = []
        
        observer.startObserving() { count in
            counts.append(count)
            expect.fulfill()
        }
        
        CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        let count2 = TestEntity.count(in: viewContext, matching: predicate)
        
        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(counts, [count1, count2])
    }
}
