//
//  CountObserverTests.swift
//  PeakCoreDataTests
//
//  Created by David Yates on 23/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import PeakCoreData

class CountObserverTests: CoreDataTests {
    
    let insertNumber = 1000
    
    func testNotifierCalledOnStartNotifier() {
        let expect = expectation(description: "")
        
        let observer = CountObserver<TestEntityString>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, 0)
        
        observer.startObserving() { count in
            XCTAssertEqual(count, 0)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testExistingData() {
        createTestEntityStringObjects(count: insertNumber)
        
        let expect = expectation(description: "")
        
        let observer = CountObserver<TestEntityString>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, insertNumber)
        
        observer.startObserving() { count in
            XCTAssertEqual(count, self.insertNumber)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testCountChanges() {
        createTestEntityStringObjects(count: insertNumber)
        let observer = CountObserver<TestEntityString>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, insertNumber)
        createTestEntityStringObjects(count: insertNumber)
        XCTAssertEqual(observer.count, insertNumber*2)
        TestEntityString.delete(in: viewContext)
        XCTAssertEqual(observer.count, 0)
    }
    
    func testInsertCallsNotifier() {
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let observer = CountObserver<TestEntityString>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, 0)
        
        var counts: [Int] = []
        observer.startObserving() { count in
            counts.append(count)
            expect.fulfill()
        }
        
        createTestEntityStringObjects(count: insertNumber)

        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(counts, [0, insertNumber])
    }
    
    func testMultipleInsertsCallsNotifier() {
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let observer = CountObserver<TestEntityString>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, 0)
        
        var counts: [Int] = []
        observer.startObserving() { count in
            counts.append(count)
            expect.fulfill()
        }
        
        createTestEntityStringObjects(count: insertNumber)
        createTestEntityStringObjects(count: insertNumber)

        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(counts, [0, insertNumber*2])
    }
    
    func testDeleteCallsNotifier() {
        createTestEntityStringObjects(count: insertNumber)
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let observer = CountObserver<TestEntityString>(predicate: nil, context: viewContext)
        XCTAssertEqual(observer.count, insertNumber)
        
        var counts: [Int] = []
        observer.startObserving() { count in
            counts.append(count)
            expect.fulfill()
        }
        
        TestEntityString.delete(in: viewContext)
        
        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(counts, [insertNumber, 0])
    }
    
    func testFetchedCountWithPredicate() {
        createTestEntityStringObjects(count: insertNumber)
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let predicate = NSPredicate(stringBeginsWith: "A", keyPath: #keyPath(TestEntityString.uniqueID))
        let count1 = TestEntityString.count(in: viewContext, matching: predicate)
        
        let observer = CountObserver<TestEntityString>(predicate: predicate, context: viewContext)
        XCTAssertEqual(observer.count, count1)
        
        var counts: [Int] = []
        
        observer.startObserving() { count in
            counts.append(count)
            expect.fulfill()
        }
        
        createTestEntityStringObjects(count: insertNumber)
        let count2 = TestEntityString.count(in: viewContext, matching: predicate)
        
        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(counts, [count1, count2])
    }
}
