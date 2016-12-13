//
//  TestManagedObjectType.swift
//  THRCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest

class TestManagedObjectType: TestCase {
    
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
        TestEntity.insertObject(withUniqueKeyValue: id, inContext: context)
        let object = TestEntity.materialiseObject(withUniqueKeyValue: id, inContext: context)
        XCTAssertNotNil(object, "")
    }
    
    func testFetchObjectMethod() {
        let context = coreDataManager.mainContext
        let id = UUID().uuidString
        TestEntity.insertObject(withUniqueKeyValue: id, inContext: context)
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
        TestEntity.delete(inContext: coreDataManager.mainContext)
        coreDataManager.save(context: context)
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
}
