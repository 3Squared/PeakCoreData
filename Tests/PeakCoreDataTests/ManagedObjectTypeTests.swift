//
//  TestManagedObjectType.swift
//  PeakCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import PeakCoreData

class ManagedObjectTypeTests: CoreDataTests {
    
    func testFetchObject() {
        let id1 = UUID().uuidString
        TestEntityString.insert(withID: id1, context: viewContext)
        XCTAssertNotNil(TestEntityString.fetch(withID: id1, context: viewContext))
        
        let id2 = Int32.random(in: 0..<Int32.max)
        TestEntityInt.insert(withID: id2, context: viewContext)
        XCTAssertNotNil(TestEntityInt.fetch(withID: id2, context: viewContext))
    }
    
    func testFirstMatchingPredicate() {
        let id1 = UUID().uuidString
        TestEntityString.insert(withID: id1, context: viewContext)
        let predicate1 = TestEntityString.uniqueIDValue(equalTo: id1)
        XCTAssertNotNil(TestEntityString.first(in: viewContext, matching: predicate1))
        
        let id2 = Int32.random(in: 0..<Int32.max)
        TestEntityInt.insert(withID: id2, context: viewContext)
        let predicate2 = TestEntityInt.uniqueIDValue(equalTo: id2)
        XCTAssertNotNil(TestEntityInt.first(in: viewContext, matching: predicate2))
    }
    
    func testFirstConfigured() {
        let count = 100
        
        createTestEntityStringObjects(count: count)
        
        XCTAssertNotNil(TestEntityString.first(in: viewContext) {
            $0.predicate = NSPredicate(equalTo: "Item " + String(45), keyPath: #keyPath(TestEntityString.title))
        })
        
        createTestEntityIntObjects(count: count)
        
        XCTAssertNotNil(TestEntityInt.first(in: viewContext) {
            $0.predicate = NSPredicate(equalTo: "Item " + String(45), keyPath: #keyPath(TestEntityInt.title))
        })
    }
    
    func testInsertAndDeleteAll() {
        let count = 100
        
        createTestEntityStringObjects(count: count)
        
        XCTAssertEqual(TestEntityString.count(in: viewContext), count, "Count before delete should be same as count")
        
        TestEntityString.delete(in: viewContext)
        
        XCTAssertEqual(TestEntityString.count(in: viewContext), 0, "Count after delete should be 0")
        
        createTestEntityIntObjects(count: count)
        
        XCTAssertEqual(TestEntityInt.count(in: viewContext), count, "Count before delete should be same as count")
        
        TestEntityInt.delete(in: viewContext)
        
        XCTAssertEqual(TestEntityInt.count(in: viewContext), 0, "Count after delete should be 0")
    }
    
    func testInsertAndDeleteSingleObject() {
        let count = 2
        
        let newObjects1 = createTestEntityStringObjects(count: count)
        let itemToDelete1 = newObjects1.first!
        XCTAssertEqual(TestEntityString.count(in: viewContext), count)
        
        let predicate1 = TestEntityString.uniqueIDValue(equalTo: itemToDelete1.uniqueIDValue)
        TestEntityString.delete(in: viewContext, matching: predicate1)
        
        XCTAssertEqual(TestEntityString.count(in: viewContext), count-1)
        
        let newObjects2 = createTestEntityIntObjects(count: count)
        let itemToDelete2 = newObjects2.first!
        
        XCTAssertEqual(TestEntityInt.count(in: viewContext), count)
        
        let predicate2 = TestEntityInt.uniqueIDValue(equalTo: itemToDelete2.uniqueIDValue)
        TestEntityInt.delete(in: viewContext, matching: predicate2)
        
        XCTAssertEqual(TestEntityInt.count(in: viewContext), count-1)
    }
    
    func testInsertOrFetchObject() {
        let id1 = UUID().uuidString
        let item1 = TestEntityString.fetchOrInsert(withID: id1, context: viewContext, cache: cache)
        let item2 = TestEntityString.fetchOrInsert(withID: id1, context: viewContext, cache: cache)
        XCTAssertEqual(item1, item2)
        
        let id2 = Int32.random(in: 0..<Int32.max)
        let item3 = TestEntityInt.fetchOrInsert(withID: id2, context: viewContext, cache: cache)
        let item4 = TestEntityInt.fetchOrInsert(withID: id2, context: viewContext, cache: cache)
        XCTAssertEqual(item3, item4)
    }
    
    func testBatchTestEntityInsertOrUpdate() {
        let expectedCount = 100
        let intermediateItems = createTestEntityStringIntermediates(count: expectedCount)
        
        XCTAssertEqual(TestEntityString.count(in: viewContext), (expectedCount/2), "Count before update should be equal to half expected count")

        TestEntityString.insertOrUpdate(intermediates: intermediateItems, context: viewContext, cache: cache) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
        }
        
        XCTAssertEqual(TestEntityString.count(in: viewContext), expectedCount, "Count after update should be equal to expected count")
        
        let intermediateItems2 = createTestEntityIntIntermediates(count: expectedCount)
        
        XCTAssertEqual(TestEntityInt.count(in: viewContext), (expectedCount/2), "Count before update should be equal to half expected count")

        TestEntityInt.insertOrUpdate(intermediates: intermediateItems2, context: viewContext, cache: cache) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
        }
        
        XCTAssertEqual(TestEntityInt.count(in: viewContext), expectedCount, "Count after update should be equal to expected count")
    }
    
    func testBatchInsertCreatesDuplicatesInSomeSituations() {
        let expectedCount = 10
        let intermediateItems = createTestEntityStringIntermediates(count: expectedCount)
        
        TestEntityString.insertOrUpdate(intermediates: intermediateItems, context: viewContext, cache: cache) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
            
            TestEntityString.insertOrUpdate(intermediates: intermediateItems, context: viewContext, cache: cache) {
                (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
        }
        
        // 10 unique ID exist, but because the optimised batch caches the inserted objects, it does not know about them.
        XCTAssertTrue(TestEntityString.count(in: viewContext) > expectedCount, "Count after update should be greater than the expected count")
        
        let intermediateItems2 = createTestEntityIntIntermediates(count: expectedCount)
        
        TestEntityInt.insertOrUpdate(intermediates: intermediateItems2, context: viewContext, cache: cache) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
            
            TestEntityInt.insertOrUpdate(intermediates: intermediateItems2, context: viewContext, cache: cache) {
                (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
        }
        
        // 10 unique ID exist, but because the optimised batch caches the inserted objects, it does not know about them.
        XCTAssertTrue(TestEntityInt.count(in: viewContext) > expectedCount, "Count after update should be greater than the expected count")
    }
    
    func testBatchTestEntityInsertPerformance() {
        let insertCount = 100
        let intermediateItems = createTestEntityStringIntermediates(count: insertCount)
        measure {
            TestEntityString.insertOrUpdate(intermediates: intermediateItems, context: viewContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            TestEntityString.insertOrUpdate(intermediates: intermediateItems, context: viewContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            XCTAssertEqual(TestEntityString.count(in: viewContext), insertCount)
        }
    }
    
    func testBatchTestEntityIntInsertPerformance() {
        let insertCount = 100
        let intermediateItems = createTestEntityIntIntermediates(count: insertCount)
        measure {
            TestEntityInt.insertOrUpdate(intermediates: intermediateItems, context: viewContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            TestEntityInt.insertOrUpdate(intermediates: intermediateItems, context: viewContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            XCTAssertEqual(TestEntityInt.count(in: viewContext), insertCount)
        }
    }
    
    func testBatchTestEntityInsertPerformanceWithCache() {
        // The cache starts to significantly out-perform the non-cache version at 10,000
        let insertCount = 100
        let intermediateItems = createTestEntityStringIntermediates(count: insertCount)
        measure {
            TestEntityString.insertOrUpdate(intermediates: intermediateItems, context: viewContext, cache: cache) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            TestEntityString.insertOrUpdate(intermediates: intermediateItems, context: viewContext, cache: cache) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            XCTAssertEqual(TestEntityString.count(in: viewContext), insertCount)
        }
    }
    
    func testBatchTestEntityIntInsertPerformanceWithCache() {
        // The cache starts to significantly out-perform the non-cache version at 10,000
        let insertCount = 100
        let intermediateItems = createTestEntityIntIntermediates(count: insertCount)
        measure {
            TestEntityInt.insertOrUpdate(intermediates: intermediateItems, context: viewContext, cache: cache) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            TestEntityInt.insertOrUpdate(intermediates: intermediateItems, context: viewContext, cache: cache) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            XCTAssertEqual(TestEntityInt.count(in: viewContext), insertCount)
        }
    }
    
    func testNonBatchTestEntityInsertPerformance() {
        let insertCount = 100
        let intermediateItems = createTestEntityStringIntermediates(count: insertCount)
        measure {
            for intermediate in intermediateItems {
                TestEntityString.fetchOrInsert(withID: intermediate.uniqueID, context: viewContext) { entity in
                    entity.title = intermediate.title
                }
            }
            
            for intermediate in intermediateItems {
                TestEntityString.fetchOrInsert(withID: intermediate.uniqueID, context: viewContext) { entity in
                    entity.title = intermediate.title
                }
            }
            
            XCTAssertEqual(TestEntityString.count(in: viewContext), insertCount)
        }
    }
    
    func testNonBatchTestEntityIntInsertPerformance() {
        let insertCount = 100
        let intermediateItems = createTestEntityIntIntermediates(count: insertCount)
        measure {
            for intermediate in intermediateItems {
                TestEntityInt.fetchOrInsert(withID: intermediate.uniqueID, context: viewContext) { entity in
                    entity.title = intermediate.title
                }
            }
            
            for intermediate in intermediateItems {
                TestEntityInt.fetchOrInsert(withID: intermediate.uniqueID, context: viewContext) { entity in
                    entity.title = intermediate.title
                }
            }
            
            XCTAssertEqual(TestEntityInt.count(in: viewContext), insertCount)
        }
    }
    
    func testNonBatchTestEntityInsertPerformanceWithCache() {
        let insertCount = 100
        let intermediateItems = createTestEntityStringIntermediates(count: insertCount)
        measure {
            for intermediate in intermediateItems {
                TestEntityString.fetchOrInsert(withID: intermediate.uniqueID, context: viewContext, cache: cache) { entity in
                    entity.title = intermediate.title
                }
            }
            
            for intermediate in intermediateItems {
                TestEntityString.fetchOrInsert(withID: intermediate.uniqueID, context: viewContext, cache: cache) { entity in
                    entity.title = intermediate.title
                }
            }
            
            XCTAssertEqual(TestEntityString.count(in: viewContext), insertCount)
        }
    }
    
    func testNonBatchTestEntityIntInsertPerformanceWithCache() {
        let insertCount = 100
        let intermediateItems = createTestEntityIntIntermediates(count: insertCount)
        measure {
            for intermediate in intermediateItems {
                TestEntityInt.fetchOrInsert(withID: intermediate.uniqueID, context: viewContext, cache: cache) { entity in
                    entity.title = intermediate.title
                }
            }
            
            for intermediate in intermediateItems {
                TestEntityInt.fetchOrInsert(withID: intermediate.uniqueID, context: viewContext, cache: cache) { entity in
                    entity.title = intermediate.title
                }
            }
            
            XCTAssertEqual(TestEntityInt.count(in: viewContext), insertCount)
        }
    }
    
    func testEncodingTestEntityToData() {
        let id = UUID().uuidString
        let item1 = TestEntityString.fetchOrInsert(withID: id, context: viewContext, cache: cache)
        item1.title = "Hello"
        
        let data = try! item1.encode(to: TestEntityStringJSON.self, encoder: JSONEncoder())
        
        XCTAssertNotNil(data)
        
        let json = String(data: data, encoding: .utf8)
        
        XCTAssertEqual(json!, "{\"id\":\"\(item1.uniqueID!)\",\"title\":\"\(item1.title!)\"}")
    }
    
    func testEncodingTestEntityIntToData() {
        let id = Int32.random(in: 0..<Int32.max)
        let item1 = TestEntityInt.fetchOrInsert(withID: id, context: viewContext, cache: cache)
        item1.title = "Hello"
        
        let data = try! item1.encode(to: TestEntityIntJSON.self, encoder: JSONEncoder())
        
        XCTAssertNotNil(data)
        
        let json = String(data: data, encoding: .utf8)
        
        XCTAssertEqual(json!, "{\"id\":\(item1.uniqueID),\"title\":\"\(item1.title!)\"}")
    }
}
