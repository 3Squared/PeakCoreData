//
//  TestStack.swift
//  THRCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable
import THRCoreData

class StackTests: CoreDataTests {
    
    func testMainContext() {
        XCTAssertNotNil(mainContext, "Main context should never be nil")
        XCTAssertEqual(mainContext.concurrencyType, .mainQueueConcurrencyType, "Main context should have main queue concurrency type")
    }
    
    func testBackgroundContext() {
        XCTAssertNotNil(backgroundContext, "Background context should never be nil")
        XCTAssertEqual(backgroundContext.concurrencyType, .privateQueueConcurrencyType, "Background context should have private queue concurrency type")
    }
    
    func testSamePersistentStoreCoordinator() {
        XCTAssertEqual(mainContext.persistentStoreCoordinator, backgroundContext.persistentStoreCoordinator, "Main and background context should share the same persistent store coordinator")
    }
    
    func testSingleStore() {
        XCTAssertTrue(mainContext.persistentStoreCoordinator!.persistentStores.count == 1, "Should only be 1 persistent store")
    }
    
    func testMainContextChildContext() {
        let childContext = coreDataManager.createChildContext(withConcurrencyType: .mainQueueConcurrencyType)
        XCTAssertNotNil(childContext, "")
        XCTAssertEqual(childContext.parent, mainContext, "Parent of main child queue context should be main context")
    }
    
    func testBackgroundContextChildContext() {
        let childContext = coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        XCTAssertNotNil(childContext, "")
        XCTAssertEqual(childContext.parent, backgroundContext, "Parent of private queue child context should be background context")
    }
    
    func testChildContextIsIndependentOfMainContext() {
        let childContext = self.coreDataManager.createChildContext(withConcurrencyType: .mainQueueConcurrencyType)
        CoreDataTests.createTestManagedObjects(inContext: childContext, count: 100)
        let count = TestEntity.count(inContext: mainContext)
        XCTAssertTrue(count == 0, "Count should be 0")
    }
    
    func testChildContextIsIndependentOfBackgroundContext() {
        let childContext = self.coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        CoreDataTests.createTestManagedObjects(inContext: childContext, count: 100)
        let count = TestEntity.count(inContext: backgroundContext)
        XCTAssertTrue(count == 0, "Count should be 0")
    }
}
