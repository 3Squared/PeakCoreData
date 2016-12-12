//
//  THRCoreDataTests.swift
//  THRCoreDataTests
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import THRCoreData

class THRCoreDataTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: type(of: self))
        coreDataManager = CoreDataManager(modelName: "TestModel", storeType: .inMemory, bundle: bundle)
    }
    
    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }
    
    func testMainContext() {
        let mainContext = coreDataManager.mainContext
        XCTAssertNotNil(mainContext, "")
        XCTAssertEqual(mainContext.concurrencyType, .mainQueueConcurrencyType, "")
    }
    
    func testBackgroundContext() {
        let backgroundContext = coreDataManager.backgroundContext
        XCTAssertNotNil(backgroundContext, "")
        XCTAssertEqual(backgroundContext.concurrencyType, .privateQueueConcurrencyType, "")
    }
    
    func testMainContextAndBackgroundContextUseSamePersistentStoreCoordinator() {
        let mainContext = coreDataManager.mainContext
        let backgroundContext = coreDataManager.backgroundContext
        XCTAssertEqual(mainContext.persistentStoreCoordinator, backgroundContext.persistentStoreCoordinator, "")
    }
    
    func testStoreCoordinatorHasASingleStore() {
        let mainContext = coreDataManager.mainContext
        XCTAssertTrue(mainContext.persistentStoreCoordinator!.persistentStores.count == 1, "")
    }
    
    func testInsertAndSaveInMainContext() {
        
        // Check count in main context is 0
        
        let context = coreDataManager.mainContext
        
        let count1 = TestEntity.count(inContext: context)
        XCTAssertTrue(count1 == 0, "\(count1)")
        
        let newObject = insertTestEntity(withUniqueID: "id_1", inContext: context)
        newObject.title = "This is a test object"
        XCTAssertNotNil(newObject, "")
        
        coreDataManager.saveMainContext()
        
        let count2 = TestEntity.count(inContext: context)
        XCTAssertTrue(count2 == 1, "\(count2)")
    }
    
    func testInsertAndSaveInBackgroundContextMergesInToMainContext() {
        
        // Check count in main context is 0
        
        let count1 = TestEntity.count(inContext: coreDataManager.mainContext)
        XCTAssertTrue(count1 == 0, "\(count1)")
        
        // Insert in to background context, on a background queue
        
        let context = coreDataManager.backgroundContext
        let expect = expectation(description: "Object inserted")
        context.perform {
            let newObject = self.insertTestEntity(withUniqueID: "id_1", inContext: context)
            newObject.title = "This is a test object"
            XCTAssertNotNil(newObject, "")
            self.coreDataManager.save(context: context, wait: true)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
        // Check count in private context is 1
        
        let count2 = TestEntity.count(inContext: context)
        XCTAssertTrue(count2 == 1, "\(count2)")
        
        // Check count in main context is 1 to show merging has happened
        
        let count3 = TestEntity.count(inContext: coreDataManager.mainContext)
        XCTAssertTrue(count3 == 1, "\(count3)")
    }
    
    func testInsertAndSaveInChildOfBackgroundContextMergesInToMainContext() {
        
        // Check count in main context is 0
        
        let count1 = TestEntity.count(inContext: coreDataManager.mainContext)
        XCTAssertTrue(count1 == 0, "\(count1)")
        
        // Insert in to child context, on a background queue
        
        let expect = expectation(description: "Object inserted")
        let context = self.coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        context.perform {
            let newObject = self.insertTestEntity(withUniqueID: "id_1", inContext: context)
            newObject.title = "This is a test object"
            XCTAssertNotNil(newObject, "")
            self.coreDataManager.save(context: context, wait: true)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
        // Check count in background context is 1
        
        let count2 = TestEntity.count(inContext: coreDataManager.backgroundContext)
        XCTAssertTrue(count2 == 1, "\(count2)")
        
        // Check count in main context is 1 to show merging has happened
        
        let count3 = TestEntity.count(inContext: coreDataManager.mainContext)
        XCTAssertTrue(count3 == 1, "\(count3)")
    }
    
    func testChildContextChangesAreOnlyPushedOnSave() {
        
        // Check count in main context is 0
        
        let count1 = TestEntity.count(inContext: coreDataManager.mainContext)
        XCTAssertTrue(count1 == 0, "\(count1)")
        
        // Insert in to child context, on a background queue
        
        let expect = expectation(description: "Object inserted")
        
        let context = self.coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        context.perform {
            let newObject = self.insertTestEntity(withUniqueID: "id_1", inContext: context)
            newObject.title = "This is a test object"
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
        // Check count in background context is still 0
        
        let count2 = TestEntity.count(inContext: coreDataManager.backgroundContext)
        XCTAssertTrue(count2 == 0, "\(count2)")
    }
    
    func testBatchInsertOrUpdateMethod() {
        let intermediateItems = createTestObjects(number: 100)
        
        let itemsBeforeUpdate = TestEntity.fetch(inContext: coreDataManager.mainContext)
        XCTAssertTrue(itemsBeforeUpdate.count == 50, "\(itemsBeforeUpdate.count)")

        
        TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: coreDataManager.mainContext) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
        }
        
        coreDataManager.saveMainContext()
        
        let items = TestEntity.fetch(inContext: coreDataManager.mainContext)
        XCTAssertTrue(items.count == 100, "\(items.count)")
        
        for item in items {
            XCTAssertNotNil(item.uniqueID, "")
            XCTAssertNotNil(item.title, "")
        }
    }
    
    func testBatchInsertCreatesDuplicatesInSomeSituations() {
        let intermediateItems = createTestObjects(number: 10)
        
        TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: self.coreDataManager.mainContext) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
            
            TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: self.coreDataManager.mainContext) {
                (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
        }
        
        self.coreDataManager.saveMainContext()
        let items = TestEntity.fetch(inContext: coreDataManager.mainContext)
        
        // 10 unique ID exist, but because the optimised batch caches the inserted objects, it does not know about them.
        XCTAssertTrue(items.count != 10, "\(items.count)")
    }
    
    func testBatchInsertPerformance() {
        let intermediateItems = createTestObjects(number: 1000)

        measure {
            TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: self.coreDataManager.mainContext) {
                (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            self.coreDataManager.saveMainContext()
        }
    }
    
    func testNonBatchInsertPerformance() {
        let intermediateItems = createTestObjects(number: 1000)
                
        measure {
            for intermediate in intermediateItems {
                TestEntity.fetchOrInsertObject(withUniqueKeyValue: intermediate.uniqueID, inContext: self.coreDataManager.mainContext, withConfigurationBlock: { entity in
                    entity.title = intermediate.title
                })
            }
            self.coreDataManager.saveMainContext()
        }
    }

    func testMaterialiseObjectMethod() {
        let context = coreDataManager.mainContext
        let id = UUID().uuidString
        insertTestEntity(withUniqueID: id, inContext: context)
        let object = TestEntity.materialiseObject(withUniqueKeyValue: id, inContext: context)
        XCTAssertNotNil(object, "")
    }
    
    func testFetchObjectMethod() {
        let context = coreDataManager.mainContext
        let id = UUID().uuidString
        insertTestEntity(withUniqueID: id, inContext: context)
        coreDataManager.saveMainContext()
        let object = TestEntity.fetchObject(withUniqueKeyValue: id, inContext: context)
        XCTAssertNotNil(object, "")
    }
    
    func testInsertAndDeleteAll() {
        let context = coreDataManager.mainContext
        let count = 100
        createTestObjects(inContext: context, count: count)
        coreDataManager.saveMainContext()
        let count1 = TestEntity.count(inContext: context)
        XCTAssertTrue(count1 == count, "\(count1)")
        deleteAll()
        let count2 = TestEntity.count(inContext: context)
        XCTAssertTrue(count2 == 0, "\(count2)")
    }
    
    func testInsertAndDeleteSingleObject() {
        let count = 2
        let newObjects = createTestObjects(inContext: coreDataManager.mainContext, count: count)
        let itemToDelete = newObjects.first!
        coreDataManager.saveMainContext()
        let count1 = TestEntity.count(inContext: coreDataManager.mainContext)
        XCTAssertTrue(count1 == count, "\(count1)")
        let predicate = TestEntity.uniqueObjectPredicate(withUniqueKeyValue: itemToDelete.uniqueID!)
        TestEntity.delete(inContext: coreDataManager.mainContext, matchingPredicate: predicate)
        coreDataManager.saveMainContext()
        let count2 = TestEntity.count(inContext: coreDataManager.mainContext)
        XCTAssertTrue(count2 == count-1, "\(count2)")
    }
    
    func testInsertOrFetchObjectMethod() {
        let id = UUID().uuidString
        let item1 = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: coreDataManager.mainContext)
        coreDataManager.saveMainContext()
        let item2 = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: coreDataManager.mainContext)
        XCTAssertEqual(item1, item2)
    }
    
    // MARK: - Helpers
    
    func createTestObjects(number: Int, test: (Int) -> Bool = {$0 % 2 == 0}) -> [TestEntity.JSON] {
        let context = coreDataManager.mainContext
        
        var intermediateItems: [TestEntity.JSON] = []
        
        for item in 0..<number {
            let id = UUID().uuidString
            let title = "Item " + String(item)
            let intermediate = TestEntity.JSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if test(item) {
                insertTestEntity(withUniqueID: id, inContext: context)
            }
        }
        
        coreDataManager.saveMainContext()
        return intermediateItems;
    }
    
    @discardableResult
    func createTestObjects(inContext context: NSManagedObjectContext, count: Int) -> [TestEntity] {
        var items: [TestEntity] = []
        for _ in 0..<count {
            let id = UUID().uuidString
            let newObject = insertTestEntity(withUniqueID: id, inContext: context)
            items.append(newObject)
        }
        return items
    }
    
    @discardableResult
    func insertTestEntity(withUniqueID uniqueID: String, inContext context: NSManagedObjectContext) -> TestEntity {
        let newObject = TestEntity.insertObject(withUniqueKeyValue: uniqueID, inContext: context)
        return newObject
    }
    
    func deleteAll() {
        TestEntity.delete(inContext: coreDataManager.mainContext)
        coreDataManager.saveMainContext()
    }
}
