//
//  TestCase.swift
//  THRCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable
import THRCoreData

let defaultTimeout = TimeInterval(2)

class CoreDataTests: XCTestCase {
    
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
    
    static func createTestIntermediateObjects(number: Int, inContext context: NSManagedObjectContext, test: (Int) -> Bool = { $0 % 2 == 0 }) -> [TestEntity.JSON] {
        var intermediateItems: [TestEntity.JSON] = []
        for item in 0..<number {
            let id = UUID().uuidString
            let title = "Item " + String(item)
            let intermediate = TestEntity.JSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if test(item) {
                TestEntity.insertObject(withUniqueKeyValue: id, inContext: context)
            }
        }
        return intermediateItems;
    }
    
    @discardableResult
    static func createTestManagedObjects(inContext context: NSManagedObjectContext, count: Int) -> [TestEntity] {
        var items: [TestEntity] = []
        for item in 0..<count {
            let id = UUID().uuidString
            let newObject = TestEntity.insertObject(withUniqueKeyValue: id, inContext: context)
            newObject.title = "Item " + String(item)
            items.append(newObject)
        }
        return items
    }
}
