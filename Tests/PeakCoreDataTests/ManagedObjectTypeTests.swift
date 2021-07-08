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
        TestEntity.insertObject(with: id1, in: viewContext)
        XCTAssertNotNil(TestEntity.fetchObject(with: id1, in: viewContext))
        
        let id2 = Int32.random(in: 0..<Int32.max)
        AnotherEntity.insertObject(with: id2, in: viewContext)
        XCTAssertNotNil(AnotherEntity.fetchObject(with: id2, in: viewContext))
    }
    
    func testFirstMatchingPredicate() {
        let id1 = UUID().uuidString
        TestEntity.insertObject(with: id1, in: viewContext)
        let predicate1 = TestEntity.uniqueObjectPredicate(with: id1)
        XCTAssertNotNil(TestEntity.first(in: viewContext, matching: predicate1))
        
        let id2 = Int32.random(in: 0..<Int32.max)
        AnotherEntity.insertObject(with: id2, in: viewContext)
        let predicate2 = AnotherEntity.uniqueObjectPredicate(with: id2)
        XCTAssertNotNil(AnotherEntity.first(in: viewContext, matching: predicate2))
    }
    
    func testFirstConfigured() {
        let count = 100
        
        createTestEntityObjects(count: count)
        
        XCTAssertNotNil(TestEntity.first(in: viewContext) {
            $0.predicate = NSPredicate(equalTo: "Item " + String(45), keyPath: #keyPath(TestEntity.title))
        })
        
        createAnotherEntityObjects(count: count)
        
        XCTAssertNotNil(AnotherEntity.first(in: viewContext) {
            $0.predicate = NSPredicate(equalTo: "Item " + String(45), keyPath: #keyPath(AnotherEntity.title))
        })
    }
    
    func testInsertAndDeleteAll() {
        let count = 100
        
        createTestEntityObjects(count: count)
        
        XCTAssertEqual(TestEntity.count(in: viewContext), count, "Count before delete should be same as count")
        
        TestEntity.delete(in: viewContext)
        
        XCTAssertEqual(TestEntity.count(in: viewContext), 0, "Count after delete should be 0")
        
        createAnotherEntityObjects(count: count)
        
        XCTAssertEqual(AnotherEntity.count(in: viewContext), count, "Count before delete should be same as count")
        
        AnotherEntity.delete(in: viewContext)
        
        XCTAssertEqual(AnotherEntity.count(in: viewContext), 0, "Count after delete should be 0")
    }
    
    func testInsertAndDeleteSingleObject() {
        let count = 2
        
        let newObjects1 = createTestEntityObjects(count: count)
        let itemToDelete1 = newObjects1.first!
        XCTAssertEqual(TestEntity.count(in: viewContext), count)
        
        let predicate1 = TestEntity.uniqueObjectPredicate(with: itemToDelete1.uniqueIDValue)
        TestEntity.delete(in: viewContext, matching: predicate1)
        
        XCTAssertEqual(TestEntity.count(in: viewContext), count-1)
        
        let newObjects2 = createAnotherEntityObjects(count: count)
        let itemToDelete2 = newObjects2.first!
        
        XCTAssertEqual(AnotherEntity.count(in: viewContext), count)
        
        let predicate2 = AnotherEntity.uniqueObjectPredicate(with: itemToDelete2.uniqueIDValue)
        AnotherEntity.delete(in: viewContext, matching: predicate2)
        
        XCTAssertEqual(AnotherEntity.count(in: viewContext), count-1)
    }
    
    func testInsertOrFetchObject() {
        let id1 = UUID().uuidString
        let item1 = TestEntity.fetchOrInsertObject(with: id1, in: viewContext, with: managedObjectCache)
        let item2 = TestEntity.fetchOrInsertObject(with: id1, in: viewContext, with: managedObjectCache)
        XCTAssertEqual(item1, item2)
        
        let id2 = Int32.random(in: 0..<Int32.max)
        let item3 = AnotherEntity.fetchOrInsertObject(with: id2, in: viewContext, with: managedObjectCache)
        let item4 = AnotherEntity.fetchOrInsertObject(with: id2, in: viewContext, with: managedObjectCache)
        XCTAssertEqual(item3, item4)
    }
    
    func testBatchTestEntityInsertOrUpdate() {
        let expectedCount = 100
        let intermediateItems = createTestEntityIntermediates(count: expectedCount)
        
        XCTAssertEqual(TestEntity.count(in: viewContext), (expectedCount/2), "Count before update should be equal to half expected count")

        TestEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext, with: managedObjectCache) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
        }
        
        XCTAssertEqual(TestEntity.count(in: viewContext), expectedCount, "Count after update should be equal to expected count")
        
        let intermediateItems2 = createAnotherEntityIntermediates(count: expectedCount)
        
        XCTAssertEqual(AnotherEntity.count(in: viewContext), (expectedCount/2), "Count before update should be equal to half expected count")

        AnotherEntity.insertOrUpdate(intermediates: intermediateItems2, in: viewContext, with: managedObjectCache) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
        }
        
        XCTAssertEqual(AnotherEntity.count(in: viewContext), expectedCount, "Count after update should be equal to expected count")
    }
    
    func testBatchInsertCreatesDuplicatesInSomeSituations() {
        let expectedCount = 10
        let intermediateItems = createTestEntityIntermediates(count: expectedCount)
        
        TestEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext, with: managedObjectCache) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
            
            TestEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext, with: managedObjectCache) {
                (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
        }
        
        // 10 unique ID exist, but because the optimised batch caches the inserted objects, it does not know about them.
        XCTAssertTrue(TestEntity.count(in: viewContext) > expectedCount, "Count after update should be greater than the expected count")
        
        let intermediateItems2 = createAnotherEntityIntermediates(count: expectedCount)
        
        AnotherEntity.insertOrUpdate(intermediates: intermediateItems2, in: viewContext, with: managedObjectCache) {
            (intermediate, managedObject) in
            managedObject.title = intermediate.title
            
            AnotherEntity.insertOrUpdate(intermediates: intermediateItems2, in: viewContext, with: managedObjectCache) {
                (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
        }
        
        // 10 unique ID exist, but because the optimised batch caches the inserted objects, it does not know about them.
        XCTAssertTrue(AnotherEntity.count(in: viewContext) > expectedCount, "Count after update should be greater than the expected count")
    }
    
    func testBatchTestEntityInsertPerformance() {
        let insertCount = 100
        let intermediateItems = createTestEntityIntermediates(count: insertCount)
        measure {
            TestEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            TestEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            XCTAssertEqual(TestEntity.count(in: viewContext), insertCount)
        }
    }
    
    func testBatchAnotherEntityInsertPerformance() {
        let insertCount = 100
        let intermediateItems = createAnotherEntityIntermediates(count: insertCount)
        measure {
            AnotherEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            AnotherEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            XCTAssertEqual(AnotherEntity.count(in: viewContext), insertCount)
        }
    }
    
    func testBatchTestEntityInsertPerformanceWithCache() {
        // The cache starts to significantly out-perform the non-cache version at 10,000
        let insertCount = 100
        let intermediateItems = createTestEntityIntermediates(count: insertCount)
        measure {
            TestEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext, with: managedObjectCache) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            TestEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext, with: managedObjectCache) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            XCTAssertEqual(TestEntity.count(in: viewContext), insertCount)
        }
    }
    
    func testBatchAnotherEntityInsertPerformanceWithCache() {
        // The cache starts to significantly out-perform the non-cache version at 10,000
        let insertCount = 100
        let intermediateItems = createAnotherEntityIntermediates(count: insertCount)
        measure {
            AnotherEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext, with: managedObjectCache) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            AnotherEntity.insertOrUpdate(intermediates: intermediateItems, in: viewContext, with: managedObjectCache) { (intermediate, managedObject) in
                managedObject.title = intermediate.title
            }
            
            XCTAssertEqual(AnotherEntity.count(in: viewContext), insertCount)
        }
    }
    
    func testNonBatchTestEntityInsertPerformance() {
        let insertCount = 100
        let intermediateItems = createTestEntityIntermediates(count: insertCount)
        measure {
            for intermediate in intermediateItems {
                TestEntity.fetchOrInsertObject(with: intermediate.uniqueID, in: viewContext) { entity in
                    entity.title = intermediate.title
                }
            }
            
            for intermediate in intermediateItems {
                TestEntity.fetchOrInsertObject(with: intermediate.uniqueID, in: viewContext) { entity in
                    entity.title = intermediate.title
                }
            }
            
            XCTAssertEqual(TestEntity.count(in: viewContext), insertCount)
        }
    }
    
    func testNonBatchAnotherEntityInsertPerformance() {
        let insertCount = 100
        let intermediateItems = createAnotherEntityIntermediates(count: insertCount)
        measure {
            for intermediate in intermediateItems {
                AnotherEntity.fetchOrInsertObject(with: intermediate.uniqueID, in: viewContext) { entity in
                    entity.title = intermediate.title
                }
            }
            
            for intermediate in intermediateItems {
                AnotherEntity.fetchOrInsertObject(with: intermediate.uniqueID, in: viewContext) { entity in
                    entity.title = intermediate.title
                }
            }
            
            XCTAssertEqual(AnotherEntity.count(in: viewContext), insertCount)
        }
    }
    
    func testNonBatchTestEntityInsertPerformanceWithCache() {
        let insertCount = 100
        let intermediateItems = createTestEntityIntermediates(count: insertCount)
        measure {
            for intermediate in intermediateItems {
                TestEntity.fetchOrInsertObject(with: intermediate.uniqueID, in: viewContext, with: managedObjectCache) { entity in
                    entity.title = intermediate.title
                }
            }
            
            for intermediate in intermediateItems {
                TestEntity.fetchOrInsertObject(with: intermediate.uniqueID, in: viewContext, with: managedObjectCache) { entity in
                    entity.title = intermediate.title
                }
            }
            
            XCTAssertEqual(TestEntity.count(in: viewContext), insertCount)
        }
    }
    
    func testNonBatchAnotherEntityInsertPerformanceWithCache() {
        let insertCount = 100
        let intermediateItems = createAnotherEntityIntermediates(count: insertCount)
        measure {
            for intermediate in intermediateItems {
                AnotherEntity.fetchOrInsertObject(with: intermediate.uniqueID, in: viewContext, with: managedObjectCache) { entity in
                    entity.title = intermediate.title
                }
            }
            
            for intermediate in intermediateItems {
                AnotherEntity.fetchOrInsertObject(with: intermediate.uniqueID, in: viewContext, with: managedObjectCache) { entity in
                    entity.title = intermediate.title
                }
            }
            
            XCTAssertEqual(AnotherEntity.count(in: viewContext), insertCount)
        }
    }
    
    func testEncodingTestEntityToData() {
        let id = UUID().uuidString
        let item1 = TestEntity.fetchOrInsertObject(with: id, in: viewContext, with: managedObjectCache)
        item1.title = "Hello"
        
        let data = try! item1.encode(to: TestEntityJSON.self, encoder: JSONEncoder())
        
        XCTAssertNotNil(data)
        
        let json = String(data: data, encoding: .utf8)
        
        XCTAssertEqual(json!, "{\"id\":\"\(item1.uniqueID!)\",\"title\":\"\(item1.title!)\"}")
    }
    
    func testEncodingAnotherEntityToData() {
        let id = Int32.random(in: 0..<Int32.max)
        let item1 = AnotherEntity.fetchOrInsertObject(with: id, in: viewContext, with: managedObjectCache)
        item1.title = "Hello"
        
        let data = try! item1.encode(to: AnotherEntityJSON.self, encoder: JSONEncoder())
        
        XCTAssertNotNil(data)
        
        let json = String(data: data, encoding: .utf8)
        
        XCTAssertEqual(json!, "{\"id\":\(item1.uniqueID),\"title\":\"\(item1.title!)\"}")
    }
}
