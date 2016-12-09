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
        deleteAll()
        coreDataManager = nil
        super.tearDown()
    }
    
    func testViewContext() {
        let viewContext = coreDataManager.mainContext
        XCTAssertNotNil(viewContext, "")
        XCTAssertEqual(viewContext.concurrencyType, .mainQueueConcurrencyType, "")
    }
    
    func testBackgroundContext() {
        let backgroundContext = coreDataManager.backgroundContext
        XCTAssertNotNil(backgroundContext, "")
        XCTAssertEqual(backgroundContext.concurrencyType, .privateQueueConcurrencyType, "")
    }
    
    func testViewContextAndPrivateContextUseSamePersistentStoreCoordinator() {
        let viewContext = coreDataManager.mainContext
        let backgroundContext = coreDataManager.backgroundContext
        XCTAssertEqual(viewContext.persistentStoreCoordinator, backgroundContext.persistentStoreCoordinator, "")
    }
    
    func testStoreCoordinatorHasASingleStore() {
        let viewContext = coreDataManager.mainContext
        XCTAssertTrue(viewContext.persistentStoreCoordinator!.persistentStores.count == 1, "")
    }
    
    func testInsertAndSaveInViewContext() {
        
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
        
        // Insert in to background context
        
        let context = coreDataManager.backgroundContext
        
        let newObject = insertTestEntity(withUniqueID: "id_1", inContext: context)
        newObject.title = "This is a test object"
        XCTAssertNotNil(newObject, "")
        
        coreDataManager.saveBackgroundContext()
        
        // Check count in private context is 1
        
        let count2 = TestEntity.count(inContext: context)
        XCTAssertTrue(count2 == 1, "\(count2)")
        
        // Check count in main context is 1 to show merging has happened
        
        let count3 = TestEntity.count(inContext: coreDataManager.mainContext)
        XCTAssertTrue(count3 == 1, "\(count3)")
    }
    
    func testBatchInsertOrUpdateMethod() {
        let context = coreDataManager.mainContext
        
        var intermediateItems: [TestEntity.JSON] = []
        
        for item in 0..<100 {
            let id = UUID().uuidString
            let title = "Item " + String(item)
            let intermediate = TestEntity.JSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if item % 2 == 0 {
                insertTestEntity(withUniqueID: id, inContext: context)
            }
        }
        
        coreDataManager.saveMainContext()
        
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
