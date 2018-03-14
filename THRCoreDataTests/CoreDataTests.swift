//
//  TestCase.swift
//  THRCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import THRCoreData

let defaultTimeout = TimeInterval(2)

class CoreDataTests: XCTestCase, PersistentContainerSettable {
    
    var persistentContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        let testBundle = Bundle(for: type(of: self))
        let model = NSManagedObjectModel.mergedModel(from: [testBundle])
        persistentContainer = NSPersistentContainer(name: "TestModel", managedObjectModel: model!)
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print(error)
            }
        }
    }
    
    override func tearDown() {
        persistentContainer = nil
        super.tearDown()
    }
    
    static func createTestIntermediateObjects(number: Int, in context: NSManagedObjectContext, test: (Int) -> Bool = { $0 % 2 == 0 }) -> [TestEntityJSON] {
        var intermediateItems: [TestEntityJSON] = []
        for item in 0..<number {
            let id = UUID().uuidString
            let title = "Item " + String(item)
            let intermediate = TestEntityJSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if test(item) {
                TestEntity.insertObject(with: id, in: context)
            }
        }
        return intermediateItems
    }
    
    @discardableResult
    static func createTestManagedObjects(in context: NSManagedObjectContext, count: Int) -> [TestEntity] {
        var items: [TestEntity] = []
        for item in 0..<count {
            let id = UUID().uuidString
            let newObject = TestEntity.insertObject(with: id, in: context)
            newObject.title = "Item " + String(item)
            items.append(newObject)
        }
        return items
    }
}
