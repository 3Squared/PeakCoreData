//
//  ManagedObjectCacheTests.swift
//  PeakCoreData
//
//  Created by David Yates on 02/04/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import PeakCoreData

class ManagedObjectCacheTests: CoreDataTests {
    
    func testCache() throws {
        let cache = Cache<String, Int>()
        var evictedNumbers: [Int] = []
        cache.onObjectEviction = { object in
            evictedNumbers.append(object)
        }
        cache.countLimit = 2
        
        cache.insert(1, forKey: "One")
        XCTAssertEqual(cache.value(forKey: "One"), 1)
        XCTAssertEqual(evictedNumbers, [])
        
        cache.insert(2, forKey: "Two")
        XCTAssertEqual(cache.value(forKey: "Two"), 2)
        XCTAssertEqual(evictedNumbers, [])
        
        cache.insert(3, forKey: "Three")
        XCTAssertEqual(cache.value(forKey: "Three"), 3)
        XCTAssertEqual(evictedNumbers, [1])
        
        cache.insert(4, forKey: "Four")
        XCTAssertEqual(cache.value(forKey: "Four"), 4)
        XCTAssertEqual(evictedNumbers, [1, 2])
        
        cache.onObjectEviction = nil
        
        cache.insert(5, forKey: "Five")
        XCTAssertEqual(cache.value(forKey: "Five"), 5)
        XCTAssertEqual(evictedNumbers, [1, 2])
    }
    
    func testCacheRemoveValue() throws {
        let cache = Cache<String, Int>()
        var evictedNumbers: [Int] = []
        cache.onObjectEviction = { object in
            evictedNumbers.append(object)
        }
        cache.insert(1, forKey: "One")
        XCTAssertEqual(cache.value(forKey: "One"), 1)
        XCTAssertEqual(evictedNumbers, [])
        
        cache.removeValue(forKey: "One")
        XCTAssertEqual(cache.value(forKey: "One"), nil)
        XCTAssertEqual(evictedNumbers, [1])
    }
    
    func testCacheRemovalAll() throws {
        let cache = Cache<String, Int>()
        var evictedNumbers: [Int] = []
        cache.onObjectEviction = { object in
            evictedNumbers.append(object)
        }
        cache.insert(1, forKey: "One")
        XCTAssertEqual(cache.value(forKey: "One"), 1)
        XCTAssertEqual(evictedNumbers, [])
        
        cache.clearCache()
        XCTAssertEqual(cache.value(forKey: "One"), nil)
        XCTAssertEqual(evictedNumbers, [1])
    }
    
    func testCacheCosts() throws {
        let cache = Cache<String, Int>()
        var evictedNumbers: [Int] = []
        cache.onObjectEviction = { object in
            evictedNumbers.append(object)
        }
        cache.totalCostLimit = 20
        
        cache.insert(1, forKey: "One", cost: 10)
        XCTAssertEqual(cache.value(forKey: "One"), 1)
        XCTAssertEqual(evictedNumbers, [])
        
        cache.insert(2, forKey: "Two", cost: 10)
        XCTAssertEqual(cache.value(forKey: "Two"), 2)
        XCTAssertEqual(evictedNumbers, [])
        
        cache.insert(3, forKey: "Three", cost: 10)
        XCTAssertEqual(cache.value(forKey: "Three"), 3)
        XCTAssertEqual(evictedNumbers, [1])
        
        cache.insert(4, forKey: "Four", cost: 10)
        XCTAssertEqual(cache.value(forKey: "Four"), 4)
        XCTAssertEqual(evictedNumbers, [1, 2])
        
        cache.onObjectEviction = nil
        
        cache.insert(5, forKey: "Five", cost: 10)
        XCTAssertEqual(cache.value(forKey: "Five"), 5)
        XCTAssertEqual(evictedNumbers, [1, 2])
    }
    
    func testRegisterCreatesPermanentIDs() throws {
        let insertNumber = 10
        let testEntities = createTestEntityObjects(count: insertNumber)
        XCTAssertEqual((testEntities.filter { $0.objectID.isTemporaryID }).count, insertNumber)
        let anotherEntities = createAnotherEntityObjects(count: insertNumber)
        XCTAssertEqual((anotherEntities.filter { $0.objectID.isTemporaryID }).count, insertNumber)
        
        managedObjectCache.register(testEntities, in: viewContext)
        managedObjectCache.register(anotherEntities, in: viewContext)

        XCTAssertEqual((testEntities.filter { $0.objectID.isTemporaryID }).count, 0)
        XCTAssertEqual((anotherEntities.filter { $0.objectID.isTemporaryID }).count, 0)
    }
    
    func testRegister() throws {
        let insertNumber = 10
        let testEntities = createTestEntityObjects(count: insertNumber)
        let anotherEntities = createAnotherEntityObjects(count: insertNumber)

        managedObjectCache.register(testEntities, in: viewContext)
        managedObjectCache.register(anotherEntities, in: viewContext)

        testEntities.forEach { obj in
            let cached: TestEntity? = managedObjectCache.object(withUniqueID: obj.uniqueIDValue, in: viewContext)
            XCTAssertNotNil(cached)
        }
        
        anotherEntities.forEach { obj in
            let cached: AnotherEntity? = managedObjectCache.object(withUniqueID: obj.uniqueIDValue, in: viewContext)
            XCTAssertNotNil(cached)
        }
    }
}
