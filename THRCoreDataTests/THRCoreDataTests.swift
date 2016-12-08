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
        let viewContext = coreDataManager.viewContext
        XCTAssertNotNil(viewContext, "")
        XCTAssertEqual(viewContext.concurrencyType, .mainQueueConcurrencyType, "")
    }
    
    func testBackgroundContext() {
        let backgroundContext = coreDataManager.newBackgroundContext()
        XCTAssertNotNil(backgroundContext, "")
        XCTAssertEqual(backgroundContext.concurrencyType, .privateQueueConcurrencyType, "")
    }
    
    func testViewContextAndPrivateContextUseSamePersistentStoreCoordinator() {
        let viewContext = coreDataManager.viewContext
        let backgroundContext = coreDataManager.newBackgroundContext()
        XCTAssertEqual(viewContext.persistentStoreCoordinator, backgroundContext.persistentStoreCoordinator, "")
    }
    
    func testStoreCoordinatorHasASingleStore() {
        let viewContext = coreDataManager.viewContext
        XCTAssertTrue(viewContext.persistentStoreCoordinator!.persistentStores.count == 1, "")
    }
    
    func testInsertAndSaveInViewContext() {
        
        // Check count in main context is 0
        
        let context = coreDataManager.viewContext
        
        let count1 = TestEntity.count(inContext: context)
        XCTAssertTrue(count1 == 0, "\(count1)")
        
        let newObject = insertTestEntity(withUniqueID: "id_1", inContext: context)
        newObject.title = "This is a test object"
        XCTAssertNotNil(newObject, "")
        
        coreDataManager.saveChanges()
        
        let count2 = TestEntity.count(inContext: context)
        XCTAssertTrue(count2 == 1, "\(count2)")
        
        deleteAll()
    }
    
    func testInsertAndSaveInBackgroundContextMergesInToMainContext() {
        
        // Check count in main context is 0
        
        let count1 = TestEntity.count(inContext: coreDataManager.viewContext)
        XCTAssertTrue(count1 == 0, "\(count1)")
        
        // Insert in to background context
        
        let context = coreDataManager.newBackgroundContext()
        
        let newObject = insertTestEntity(withUniqueID: "id_1", inContext: context)
        newObject.title = "This is a test object"
        XCTAssertNotNil(newObject, "")
        
        // Save
        
        do {
            try context.save()
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        // Check count in private context is 1
        
        let count2 = TestEntity.count(inContext: context)
        XCTAssertTrue(count2 == 1, "\(count2)")
        
        // Check count in main context is 1 to show merging has happened
        
        let count3 = TestEntity.count(inContext: coreDataManager.viewContext)
        XCTAssertTrue(count3 == 1, "\(count3)")
        
        deleteAll()
    }
    
    func testBatchInsertOrUpdateMethod() {
        let context = coreDataManager.viewContext
        
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
        
        coreDataManager.saveChanges()
        
        TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: coreDataManager.viewContext) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
        }
        
        coreDataManager.saveChanges()
        
        let items = TestEntity.fetch(inContext: coreDataManager.viewContext)
        XCTAssertTrue(items.count == 100, "\(items.count)")
        
        for item in items {
            XCTAssertNotNil(item.uniqueID, "")
            XCTAssertNotNil(item.title, "")
        }
        
        deleteAll()
    }
    
    func testMaterialiseObjectMethod() {
        let context = coreDataManager.viewContext
        let id = UUID().uuidString
        insertTestEntity(withUniqueID: id, inContext: context)
        let object = TestEntity.materialiseObject(withUniqueKeyValue: id, inContext: context)
        XCTAssertNotNil(object, "")
        deleteAll()
    }
    
    func testFetchObjectMethod() {
        let context = coreDataManager.viewContext
        let id = UUID().uuidString
        insertTestEntity(withUniqueID: id, inContext: context)
        coreDataManager.saveChanges()
        let object = TestEntity.fetchObject(withUniqueKeyValue: id, inContext: context)
        XCTAssertNotNil(object, "")
        deleteAll()
    }
    
    func testInsertAndDeleteAll() {
        let context = coreDataManager.viewContext
        let count = 100
        createTestObjects(inContext: context, count: count)
        coreDataManager.saveChanges()
        let count1 = TestEntity.count(inContext: context)
        XCTAssertTrue(count1 == count, "\(count1)")
        deleteAll()
        let count2 = TestEntity.count(inContext: context)
        XCTAssertTrue(count2 == 0, "\(count2)")
    }
    
    func testInsertAndDeleteSingleObject() {
        let count = 2
        let newObjects = createTestObjects(inContext: coreDataManager.viewContext, count: count)
        let itemToDelete = newObjects.first!
        coreDataManager.saveChanges()
        let count1 = TestEntity.count(inContext: coreDataManager.viewContext)
        XCTAssertTrue(count1 == count, "\(count1)")
        let predicate = TestEntity.uniqueObjectPredicate(withUniqueKeyValue: itemToDelete.uniqueID!)
        TestEntity.delete(inContext: coreDataManager.viewContext, matchingPredicate: predicate)
        coreDataManager.saveChanges()
        let count2 = TestEntity.count(inContext: coreDataManager.viewContext)
        XCTAssertTrue(count2 == count-1, "\(count2)")
        deleteAll()
    }
    
    func testInsertOrFetchObjectMethod() {
        let id = UUID().uuidString
        let item1 = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: coreDataManager.viewContext)
        coreDataManager.saveChanges()
        let item2 = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: coreDataManager.viewContext)
        XCTAssertEqual(item1, item2)
        deleteAll()
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
        TestEntity.delete(inContext: coreDataManager.viewContext)
        coreDataManager.saveChanges()
    }
}
