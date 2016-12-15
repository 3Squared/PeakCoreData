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
        let mainContext = coreDataManager.mainContext
        XCTAssertNotNil(mainContext, "Main context should never be nil")
        XCTAssertEqual(mainContext.concurrencyType, .mainQueueConcurrencyType, "Main context should have main queue concurrency type")
    }
    
    func testBackgroundContext() {
        let backgroundContext = coreDataManager.backgroundContext
        XCTAssertNotNil(backgroundContext, "Background context should never be nil")
        XCTAssertEqual(backgroundContext.concurrencyType, .privateQueueConcurrencyType, "Background context should have private queue concurrency type")
    }
    
    func testSamePersistentStoreCoordinator() {
        let mainContext = coreDataManager.mainContext
        let backgroundContext = coreDataManager.backgroundContext
        XCTAssertEqual(mainContext.persistentStoreCoordinator, backgroundContext.persistentStoreCoordinator, "Main and background context should share the same persistent store coordinator")
    }
    
    func testSingleStore() {
        let mainContext = coreDataManager.mainContext
        XCTAssertTrue(mainContext.persistentStoreCoordinator!.persistentStores.count == 1, "Should only be 1 persistent store")
    }
    
    func testMainContextChildContext() {
        let childContext = coreDataManager.createChildContext(withConcurrencyType: .mainQueueConcurrencyType)
        XCTAssertNotNil(childContext, "")
        XCTAssertEqual(childContext.parent, coreDataManager.mainContext, "Parent of main child queue context should be main context")
    }
    
    func testBackgroundContextChildContext() {
        let childContext = coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        XCTAssertNotNil(childContext, "")
        XCTAssertEqual(childContext.parent, coreDataManager.backgroundContext, "Parent of private queue child context should be background context")
    }
    
    func testChildContextIsIndependentOfMainContext() {
        let childContext = self.coreDataManager.createChildContext(withConcurrencyType: .mainQueueConcurrencyType)
        CoreDataTests.createTestManagedObjects(inContext: childContext, count: 100)
        let count = TestEntity.count(inContext: coreDataManager.mainContext)
        XCTAssertTrue(count == 0, "Count should be 0")
    }
    
    func testChildContextIsIndependentOfBackgroundContext() {
        let childContext = self.coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        CoreDataTests.createTestManagedObjects(inContext: childContext, count: 100)
        let count = TestEntity.count(inContext: coreDataManager.backgroundContext)
        XCTAssertTrue(count == 0, "Count should be 0")
    }
}
