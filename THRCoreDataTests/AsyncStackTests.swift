//
//  AsyncStackTests.swift
//  THRCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable
import THRCoreData

class AsyncStackTests: XCTestCase, PersistentContainerSettable {

    var persistentContainer: PersistentContainer!
    var model: NSManagedObjectModel {
        let bundle = Bundle(for: type(of: self))
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("*** Error loading model URL for model named \(modelName) in main bundle")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("*** Error loading managed object model at url: \(modelURL)")
        }
        return model
    }
    var asyncStoreDescription: PersistentStoreDescription {
        let storeURL = PersistentContainer.defaultDirectoryURL().appendingPathComponent(modelName)
        var storeDescription = PersistentStoreDescription(url: storeURL)
        storeDescription.type = .inMemory
        storeDescription.shouldAddStoreAsynchronously = true
        return storeDescription
    }
    
    override func setUp() {
        super.setUp()
        persistentContainer = PersistentContainer(name: modelName, model: model)
    }
    
    override func tearDown() {
        super.tearDown()
        persistentContainer = nil
    }
    
    func testMainContext() {
        let testContext = mainContext
        let setupExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        persistentContainer.persistentStoreDescription = asyncStoreDescription
        persistentContainer.loadPersistentStores { result in
            didCallCompletion = true
            switch result {
            case .success(_):
                setupExpectation.fulfill()
            default:
                XCTFail("Setup should return success")
            }
        }

        XCTAssertEqual(testContext.persistentStoreCoordinator!.persistentStores.count, 0, "Should be 0 persistent stores here")
        XCTAssertFalse(didCallCompletion, "Completion should not have been called here")
        
        waitForExpectations(timeout: defaultTimeout, handler: { error in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
            XCTAssertEqual(testContext.persistentStoreCoordinator!.persistentStores.count, 1, "Should be 1 persistent store here")
        })
    }
    
    func testBackgroundContext() {
        let testContext = backgroundContext
        let setupExpectation = expectation(description: #function)
        
        var didCallCompletion = false
        persistentContainer.persistentStoreDescription = asyncStoreDescription
        persistentContainer.loadPersistentStores { result in
            didCallCompletion = true
            switch result {
            case .success(_):
                setupExpectation.fulfill()
            default:
                XCTFail("Setup should return success")
            }
        }
        
        XCTAssertEqual(testContext.persistentStoreCoordinator!.persistentStores.count, 0, "Should be 0 persistent stores here")
        XCTAssertFalse(didCallCompletion, "Completion should not have been called here")
        
        waitForExpectations(timeout: defaultTimeout, handler: { error in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didCallCompletion, "Completion should be called")
            XCTAssertEqual(testContext.persistentStoreCoordinator!.persistentStores.count, 1, "Should be 1 persistent store here")
        })
    }
    
    

    func testSamePersistentStoreCoordinator() {
        XCTAssertEqual(mainContext.persistentStoreCoordinator, backgroundContext.persistentStoreCoordinator, "Main and background context should share the same persistent store coordinator")
    }
}
