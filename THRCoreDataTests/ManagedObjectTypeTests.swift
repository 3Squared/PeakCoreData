//
//  TestManagedObjectType.swift
//  THRCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable
import THRCoreData

class ManagedObjectTypeTests: CoreDataTests {
    
    func testBatchInsertOrUpdate() {
        let expectedCount = 100
        let intermediateItems = CoreDataTests.createTestIntermediateObjects(number: expectedCount, inContext: mainContext)
        
        let countBeforeUpdate = TestEntity.count(inContext: mainContext)
        XCTAssertTrue(countBeforeUpdate == (expectedCount/2), "Count before update should be equal to half expected count")

        TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: mainContext) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
        }
        
        let countAfterUpdate = TestEntity.count(inContext: mainContext)
        XCTAssertEqual(countAfterUpdate, expectedCount, "Count after update should be equal to expected count")
    }
    
    func testBatchInsertCreatesDuplicatesInSomeSituations() {
        let expectedCount = 10
        let intermediateItems = CoreDataTests.createTestIntermediateObjects(number: expectedCount, inContext: mainContext)
        
        TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: mainContext) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
            
            TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: mainContext) {
                (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
        }
        
        let countAfterUpdate = TestEntity.count(inContext: mainContext)
        // 10 unique ID exist, but because the optimised batch caches the inserted objects, it does not know about them.
        XCTAssertTrue(countAfterUpdate > expectedCount, "Count after update should be greater than the expected count")
    }
    
    func testBatchInsertPerformance() {
        let intermediateItems = CoreDataTests.createTestIntermediateObjects(number: 100, inContext: mainContext)
        measure {
            TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: self.mainContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
        }
    }
    
    func testNonBatchInsertPerformance() {
        let intermediateItems = CoreDataTests.createTestIntermediateObjects(number: 100, inContext: mainContext)
        measure {
            for intermediate in intermediateItems {
                TestEntity.fetchOrInsertObject(withUniqueKeyValue: intermediate.uniqueID, inContext: self.mainContext) { entity in
                    entity.title = intermediate.title
                }
            }
        }
    }
    
    func testMaterialiseObject() {
        let id = UUID().uuidString
        TestEntity.insertObject(withUniqueKeyValue: id, inContext: mainContext)
        let object = TestEntity.materialiseObject(withUniqueKeyValue: id, inContext: mainContext)
        XCTAssertNotNil(object, "")
    }
    
    func testFetchObject() {
        let id = UUID().uuidString
        TestEntity.insertObject(withUniqueKeyValue: id, inContext: mainContext)
        let object = TestEntity.fetchObject(withUniqueKeyValue: id, inContext: mainContext)
        XCTAssertNotNil(object, "")
    }
    
    func testInsertAndDeleteAll() {
        let count = 100
        CoreDataTests.createTestManagedObjects(inContext: mainContext, count: count)
        let count1 = TestEntity.count(inContext: mainContext)
        XCTAssertTrue(count1 == count, "\(count1)")
        TestEntity.delete(inContext: mainContext)
        let count2 = TestEntity.count(inContext: mainContext)
        XCTAssertTrue(count2 == 0, "\(count2)")
    }
    
    func testInsertAndDeleteSingleObject() {
        let count = 2
        let newObjects = CoreDataTests.createTestManagedObjects(inContext: coreDataManager.mainContext, count: count)
        let itemToDelete = newObjects.first!
        let preDeleteCount = TestEntity.count(inContext: mainContext)
        
        XCTAssertTrue(preDeleteCount == count, "\(preDeleteCount)")
        
        let predicate = TestEntity.uniqueObjectPredicate(withUniqueKeyValue: itemToDelete.uniqueID!)
        TestEntity.delete(inContext: coreDataManager.mainContext, matchingPredicate: predicate)
        let postDeleteCount = TestEntity.count(inContext: mainContext)
        
        XCTAssertTrue(postDeleteCount == count-1, "\(postDeleteCount)")
    }
    
    func testInsertOrFetchObjectMethod() {
        let id = UUID().uuidString
        let item1 = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: mainContext)
        let item2 = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: mainContext)
        XCTAssertEqual(item1, item2)
    }
}
