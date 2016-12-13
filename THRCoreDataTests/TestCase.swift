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

class TestCase: XCTestCase {
    
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
                TestEntity.insertObject(withUniqueKeyValue: id, inContext: context)
            }
        }
        
        coreDataManager.saveMainContext()
        return intermediateItems;
    }
    
    @discardableResult
    func createTestObjects(inContext context: NSManagedObjectContext, count: Int) -> [TestEntity] {
        var items: [TestEntity] = []
        context.performAndWait {
            for _ in 0..<count {
                let id = UUID().uuidString
                let newObject = TestEntity.insertObject(withUniqueKeyValue: id, inContext: context)
                newObject.title = "Item " + id
                items.append(newObject)
            }
        }
        return items
    }
    
    func countObjects(inContext context: NSManagedObjectContext) -> Int {
        let fetchRequest = TestEntity.fetchRequest(withConfigurationBlock: nil)
        var count = 0
        context.performAndWait {
            count = try! context.count(for: fetchRequest)
        }
        return count
    }
}
