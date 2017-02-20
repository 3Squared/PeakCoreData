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
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: type(of: self))
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("*** Error loading model URL for model named \(name) in main bundle")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("*** Error loading managed object model at url: \(modelURL)")
        }
        persistentContainer = PersistentContainer(name: modelName, model: model)
        let storeURL = persistentContainer.defaultStoreURL.appendingPathComponent(modelName)

        var storeDescription = PersistentStoreDescription(url: storeURL)
        storeDescription.type = .inMemory
        storeDescription.shouldAddStoreAsynchronously = true
        
        persistentContainer.persistentStoreDescription = storeDescription
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMainContext() {
        XCTAssertEqual(mainContext.persistentStoreCoordinator!.persistentStores.count, 0)
        createStackAsynchronously { (result) in
            XCTAssertEqual(self.mainContext.persistentStoreCoordinator!.persistentStores.count, 1)
        }
        XCTAssertEqual(mainContext.persistentStoreCoordinator!.persistentStores.count, 0)
    }
    
    func testBackgroundContext() {
        XCTAssertEqual(backgroundContext.persistentStoreCoordinator!.persistentStores.count, 0)
        createStackAsynchronously { (result) in
            XCTAssertEqual(self.backgroundContext.persistentStoreCoordinator!.persistentStores.count, 1)
        }
        XCTAssertEqual(backgroundContext.persistentStoreCoordinator!.persistentStores.count, 0)
    }
    
    func testSamePersistentStoreCoordinator() {
        XCTAssertEqual(mainContext.persistentStoreCoordinator, backgroundContext.persistentStoreCoordinator, "Main and background context should share the same persistent store coordinator")
    }
    
    func createStackAsynchronously(completionHandler block: @escaping SetupCompletionType) {
        
        persistentContainer.loadPersistentStores {
            complete in
            block(complete)
        }
    }
}
