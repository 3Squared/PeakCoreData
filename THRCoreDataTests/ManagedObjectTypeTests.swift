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
    
    func testMaterialiseObject() {
        let id = UUID().uuidString
        TestEntity.insertObject(withUniqueKeyValue: id, inContext: viewContext)
        let object = TestEntity.materialiseObject(withUniqueKeyValue: id, inContext: viewContext)
        XCTAssertNotNil(object, "")
    }
    
    func testFetchObject() {
        let id = UUID().uuidString
        TestEntity.insertObject(withUniqueKeyValue: id, inContext: viewContext)
        let object = TestEntity.fetchObject(withUniqueKeyValue: id, inContext: viewContext)
        XCTAssertNotNil(object, "")
    }
    
    func testInsertAndDeleteAll() {
        let count = 100
        CoreDataTests.createTestManagedObjects(inContext: viewContext, count: count)
        
        let preDeleteCount = TestEntity.count(inContext: viewContext)
        XCTAssertEqual(preDeleteCount, count, "Count before delete should be same as count")
        
        TestEntity.delete(inContext: viewContext)
        
        let postDeleteCount = TestEntity.count(inContext: viewContext)
        XCTAssertEqual(postDeleteCount, 0, "Count after delete should be 0")
    }
    
    func testInsertAndDeleteSingleObject() {
        let count = 2
        let newObjects = CoreDataTests.createTestManagedObjects(inContext: viewContext, count: count)
        let itemToDelete = newObjects.first!
        
        let preDeleteCount = TestEntity.count(inContext: viewContext)
        XCTAssertEqual(preDeleteCount, count, "\(preDeleteCount)")
        
        let predicate = TestEntity.uniqueObjectPredicate(withUniqueKeyValue: itemToDelete.uniqueID!)
        TestEntity.delete(inContext: viewContext, matchingPredicate: predicate)
        
        let postDeleteCount = TestEntity.count(inContext: viewContext)
        XCTAssertEqual(postDeleteCount, count-1, "\(postDeleteCount)")
    }
    
    func testInsertOrFetchObjectMethod() {
        let id = UUID().uuidString
        let item1 = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: viewContext)
        let item2 = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: viewContext)
        XCTAssertEqual(item1, item2)
    }
    
    func testBatchInsertOrUpdate() {
        let expectedCount = 100
        let intermediateItems = CoreDataTests.createTestIntermediateObjects(number: expectedCount, inContext: viewContext)
        
        let countBeforeUpdate = TestEntity.count(inContext: viewContext)
        XCTAssertEqual(countBeforeUpdate, (expectedCount/2), "Count before update should be equal to half expected count")

        TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: viewContext) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
        }
        
        let countAfterUpdate = TestEntity.count(inContext: viewContext)
        XCTAssertEqual(countAfterUpdate, expectedCount, "Count after update should be equal to expected count")
    }
    
    func testBatchInsertCreatesDuplicatesInSomeSituations() {
        let expectedCount = 10
        let intermediateItems = CoreDataTests.createTestIntermediateObjects(number: expectedCount, inContext: viewContext)
        
        TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: viewContext) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
            
            TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: viewContext) {
                (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
        }
        
        let countAfterUpdate = TestEntity.count(inContext: viewContext)
        // 10 unique ID exist, but because the optimised batch caches the inserted objects, it does not know about them.
        XCTAssertTrue(countAfterUpdate > expectedCount, "Count after update should be greater than the expected count")
    }
    
    func testBatchInsertPerformance() {
        let intermediateItems = CoreDataTests.createTestIntermediateObjects(number: 100, inContext: viewContext)
        measure {
            TestEntity.insertOrUpdate(intermediates: intermediateItems, inContext: self.viewContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
        }
    }
    
    func testNonBatchInsertPerformance() {
        let intermediateItems = CoreDataTests.createTestIntermediateObjects(number: 100, inContext: viewContext)
        measure {
            for intermediate in intermediateItems {
                TestEntity.fetchOrInsertObject(withUniqueKeyValue: intermediate.uniqueID, inContext: self.viewContext) { entity in
                    entity.title = intermediate.title
                }
            }
        }
    }
    
    func testEncodingToData() {
        let id = UUID().uuidString
        let item1 = TestEntity.fetchOrInsertObject(withUniqueKeyValue: id, inContext: viewContext)
        item1.title = "Hello"
        
        let data = try! item1.encode(to: TestEntityJSON.self, encoder: JSONEncoder())
        
        XCTAssertNotNil(data)
        
        let json = String(data: data, encoding: .utf8)
        
        XCTAssertEqual(json!, "{\"id\":\"\(item1.uniqueID!)\",\"title\":\"\(item1.title!)\"}")
    }
}
