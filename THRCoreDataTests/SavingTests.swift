//
//  TestSaving.swift
//  THRCoreData
//
//  Created by David Yates on 13/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable
import THRCoreData

class SavingTests: CoreDataTests {
    
    /*
     The following tests highlight the asynchronous nature of the save method.
     In all cases, didCallCompletion will be false immediately following the call to save.
     However, once the save completion block has been called, all saves and merges should be complete.
    */

    func testSavingMainContextWithNoChanges() {
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        coreDataManager.save(context: mainContext) { result in
            didCallCompletion = true
            switch result {
            case .success(.noChanges):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return no changes outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored here")
        
        waitForExpectations(timeout: defaultTimeout, handler: { error in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
        })
    }
    
    func testSavingMainContextSucceedsAndMerges() {
        CoreDataTests.createTestManagedObjects(inContext: mainContext, count: 100)
        
        var didSaveMain = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: mainContext) { notification in
            didSaveMain = true
            return true
        }
        
        var didUpdateBackground = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextObjectsDidChange.rawValue, object: backgroundContext) { notification in
            didUpdateBackground = true
            return true
        }
        
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        coreDataManager.save(context: mainContext) { result in
            didCallCompletion = true
            switch result {
            case .success(.saved):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return saved outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored here")
        
        waitForExpectations(timeout: defaultTimeout, handler: { error in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
            XCTAssertTrue(didSaveMain, "Main context should be saved")
            XCTAssertTrue(didUpdateBackground, "Background context should be updated")
        })
    }
    
    func testSavingBackgroundContextSucceedsAndMerges() {
        CoreDataTests.createTestManagedObjects(inContext: backgroundContext, count: 100)
        
        var didSaveBackground = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: backgroundContext) { notification in
            didSaveBackground = true
            return true
        }
        
        var didUpdateMain = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextObjectsDidChange.rawValue, object: mainContext) { notification in
            didUpdateMain = true
            return true
        }
        
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        coreDataManager.save(context: backgroundContext) { result in
            didCallCompletion = true
            switch result {
            case .success(.saved):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return saved outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored here")

        waitForExpectations(timeout: defaultTimeout, handler: { error in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
            XCTAssertTrue(didSaveBackground, "Background context should be saved")
            XCTAssertTrue(didUpdateMain, "Main context should be updated")
        })
    }
    
    func testSavingChildOfMainContextSucceedsAndSavesParent() {
        let childContext = coreDataManager.createChildContext(withConcurrencyType: .mainQueueConcurrencyType)
        CoreDataTests.createTestManagedObjects(inContext: childContext, count: 100)
        
        var didSaveChild = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext) { notification in
            didSaveChild = true
            return true
        }
        
        var didSaveMain = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: mainContext) { notification in
            didSaveMain = true
            return true
        }
        
        var didUpdateBackground = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextObjectsDidChange.rawValue, object: backgroundContext) { notification in
            didUpdateBackground = true
            return true
        }
        
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        coreDataManager.save(context: childContext) {
            result in
            didCallCompletion = true
            switch result {
            case .success(.saved):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return saved outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored here")
        
        waitForExpectations(timeout: defaultTimeout, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
            XCTAssertTrue(didSaveChild, "Child context should be saved")
            XCTAssertTrue(didSaveMain, "Main context should be saved")
            XCTAssertTrue(didUpdateBackground, "Background context should be updated")
        })
    }
    
    func testSavingChildOfBackgroundContextSucceedsAndSavesParent() {
        let childContext = coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        CoreDataTests.createTestManagedObjects(inContext: childContext, count: 100)
        
        var didSaveChild = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext) { notification in
            didSaveChild = true
            return true
        }
        
        var didSaveBackground = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: backgroundContext) { notification in
            didSaveBackground = true
            return true
        }
        
        var didUpdateMain = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextObjectsDidChange.rawValue, object: mainContext) { notification in
            didUpdateMain = true
            return true
        }
        
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        coreDataManager.save(context: childContext) {
            result in
            didCallCompletion = true
            switch result {
            case .success(.saved):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return saved outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored here")
        
        waitForExpectations(timeout: defaultTimeout, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
            XCTAssertTrue(didSaveChild, "Child context should be saved")
            XCTAssertTrue(didSaveBackground, "Background context should be saved")
            XCTAssertTrue(didUpdateMain, "Main context should be updated")
        })
    }
}
