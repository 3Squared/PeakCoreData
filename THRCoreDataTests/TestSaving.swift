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

class TestSaving: TestCase {
    
    func testSavingMainContextWithNoChanges() {
        let mainContext = coreDataManager.mainContext
        
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        save(context: mainContext) { result in
            didCallCompletion = true
            switch result {
            case .success(.noChanges):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return no changes outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored")
        
        // THEN: then the main and background contexts are saved and the completion handler is called
        waitForExpectations(timeout: 1.0, handler: { error in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
        })
    }
    
    func testSavingMainContextSucceedsAndMerges() {
        let mainContext = coreDataManager.mainContext

        createTestObjects(inContext: mainContext, count: 100)
        
        var didSaveMain = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: mainContext) { notification in
            didSaveMain = true
            return true
        }
        
        var didUpdateBackground = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextObjectsDidChange.rawValue, object: coreDataManager.backgroundContext) { notification in
            didUpdateBackground = true
            return true
        }
        
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        save(context: mainContext) { result in
            didCallCompletion = true
            switch result {
            case .success(.saved):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return saved outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored")
        
        // THEN: then the main and background contexts are saved and the completion handler is called
        waitForExpectations(timeout: 1.0, handler: { error in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
            XCTAssertTrue(didSaveMain, "Main context should be saved")
            XCTAssertTrue(didUpdateBackground, "Background context should be updated")
        })
    }
    
    func testSavingBackgroundContextSucceedsAndMerges() {
        let backgroundContext = coreDataManager.backgroundContext
        
        createTestObjects(inContext: backgroundContext, count: 100)
        
        var didSaveBackground = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: backgroundContext) { notification in
            didSaveBackground = true
            return true
        }
        
        var didUpdateMain = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextObjectsDidChange.rawValue, object: coreDataManager.mainContext) { notification in
            didUpdateMain = true
            return true
        }
        
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        save(context: backgroundContext) { result in
            didCallCompletion = true
            switch result {
            case .success(.saved):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return saved outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored")

        // THEN: then the main and background contexts are saved and the completion handler is called
        waitForExpectations(timeout: 1.0, handler: { error in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
            XCTAssertTrue(didSaveBackground, "Main context should be saved")
            XCTAssertTrue(didUpdateMain, "Background context should be updated")
        })
    }
    
    func testSavingChildofMainContextSucceedsAndSavesParent() {
        let childContext = coreDataManager.createChildContext(withConcurrencyType: .mainQueueConcurrencyType)
        
        createTestObjects(inContext: childContext, count: 100)
        
        var didSaveChild = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext) { notification in
            didSaveChild = true
            return true
        }
        
        var didSaveMain = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: coreDataManager.mainContext) { notification in
            didSaveMain = true
            return true
        }
        
        var didUpdateBackground = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextObjectsDidChange.rawValue, object: coreDataManager.backgroundContext) { notification in
            didUpdateBackground = true
            return true
        }
        
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        save(context: childContext) {
            result in
            didCallCompletion = true
            switch result {
            case .success(.saved):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return saved outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored")
        
        // THEN: then all contexts are saved, synchronized and the completion handler is called
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
        
        createTestObjects(inContext: childContext, count: 100)
        
        var didSaveChild = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext) { notification in
            didSaveChild = true
            return true
        }
        
        var didSaveBackground = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: coreDataManager.backgroundContext) { notification in
            didSaveBackground = true
            return true
        }
        
        var didUpdateMain = false
        expectation(forNotification: Notification.Name.NSManagedObjectContextObjectsDidChange.rawValue, object: coreDataManager.mainContext) { notification in
            didUpdateMain = true
            return true
        }
        
        let saveExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        save(context: childContext) {
            result in
            didCallCompletion = true
            switch result {
            case .success(.saved):
                saveExpectation.fulfill()
            default:
                XCTFail("Save should return saved outcome")
            }
        }
        
        XCTAssertFalse(didCallCompletion, "Save should be ignored")
        
        // THEN: then all contexts are saved, synchronized and the completion handler is called
        waitForExpectations(timeout: defaultTimeout, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
            XCTAssertTrue(didSaveChild, "Child context should be saved")
            XCTAssertTrue(didSaveBackground, "Main context should be saved")
            XCTAssertTrue(didUpdateMain, "Background context should be updated")
        })
    }
}
