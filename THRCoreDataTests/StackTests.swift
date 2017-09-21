//
//  TestStack.swift
//  THRCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import THRCoreData

class StackTests: CoreDataTests {
    
    func testMainContext() {
        XCTAssertNotNil(mainContext, "Main context should never be nil")
        XCTAssertEqual(mainContext.concurrencyType, .mainQueueConcurrencyType, "Main context should have main queue concurrency type")
    }
    
    func testBackgroundContext() {
        let backgroundContext = persistentContainer.newBackgroundContext()
        XCTAssertNotNil(backgroundContext, "Background context should never be nil")
        XCTAssertEqual(backgroundContext.concurrencyType, .privateQueueConcurrencyType, "Background context should have private queue concurrency type")
    }
    
    func testSamePersistentStoreCoordinator() {
        let backgroundContext = persistentContainer.newBackgroundContext()
        XCTAssertEqual(mainContext.persistentStoreCoordinator, backgroundContext.persistentStoreCoordinator, "Main and background context should share the same persistent store coordinator")
    }
    
    func testSingleStore() {
        XCTAssertTrue(mainContext.persistentStoreCoordinator!.persistentStores.count == 1, "Should only be 1 persistent store")
    }
    
    func testSavingNewBackgroundContextSucceedsAndMerges() {
        let backgroundContext = persistentContainer.newBackgroundContext()
        CoreDataTests.createTestManagedObjects(inContext: backgroundContext, count: 100)
        
        var didSaveBackground = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave, object: backgroundContext) { notification in
            didSaveBackground = true
            return true
        }
        
        var didUpdateMain = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextObjectsDidChange, object: mainContext) { notification in
            didUpdateMain = true
            return true
        }
        
        let saveExpectation = expectation(description: #function)
        
        do {
            try backgroundContext.save()
            saveExpectation.fulfill()
        } catch {
            XCTFail("Save should return saved outcome")
        }

        waitForExpectations(timeout: defaultTimeout, handler: { error in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didSaveBackground, "Background context should be saved")
            XCTAssertTrue(didUpdateMain, "Main context should be updated")
        })
    }
}
