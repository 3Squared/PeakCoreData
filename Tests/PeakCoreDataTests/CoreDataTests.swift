//
//  TestCase.swift
//  PeakCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import PeakCoreData

let defaultTimeout = TimeInterval(2)

class CoreDataTests: XCTestCase, PersistentContainerSettable {
    
    var managedObjectCache: ManagedObjectCache!
    var persistentContainer: NSPersistentContainer!
    var lastIndex: Int32 = 0
    
    override func setUp() {
        super.setUp()
        
        let modelURL = Bundle.module.url(forResource:"TestModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        persistentContainer = NSPersistentContainer(name: "TestModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print(error)
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        managedObjectCache = ManagedObjectCache()
        lastIndex = 0
    }
    
    override func tearDown() {
        lastIndex = 0
        persistentContainer = nil
        managedObjectCache = nil
        super.tearDown()
    }
    
    @discardableResult
    func createTestEntityStringIntermediates(count: Int, test: (Int) -> Bool = { $0 % 2 == 0 }) -> [TestEntityStringJSON] {
        var intermediateItems: [TestEntityStringJSON] = []
        for index in 0..<count {
            let id = UUID().uuidString
            let title = "Item \(index)"
            let intermediate = TestEntityStringJSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if test(index) {
                TestEntityString.insertObject(with: id, in: viewContext)
            }
        }
        return intermediateItems
    }
    
    @discardableResult
    func createTestEntityUUIDIntermediates(count: Int, test: (Int) -> Bool = { $0 % 2 == 0 }) -> [TestEntityUUIDJSON] {
        var intermediateItems: [TestEntityUUIDJSON] = []
        for index in 0..<count {
            let id = UUID()
            let title = "Item \(index)"
            let intermediate = TestEntityUUIDJSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if test(index) {
                TestEntityUUID.insertObject(with: id, in: viewContext)
            }
        }
        return intermediateItems
    }
    
    @discardableResult
    func createTestEntityIntIntermediates(count: Int, test: (Int) -> Bool = { $0 % 2 == 0 }) -> [TestEntityIntJSON] {
        var intermediateItems: [TestEntityIntJSON] = []
        let toAdd = lastIndex + 1
        for index in 0..<count {
            let id = Int32(index) + toAdd
            lastIndex = id
            let title = "Item \(id)"
            let intermediate = TestEntityIntJSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if test(index) {
                TestEntityInt.insertObject(with: id, in: viewContext)
            }
        }
        return intermediateItems
    }
    
    @discardableResult
    func createTestEntityStringObjects(count: Int) -> [TestEntityString] {
        var items: [TestEntityString] = []
        for index in 0..<count {
            let id = UUID().uuidString
            let newObject = TestEntityString.insertObject(with: id, in: viewContext) {
                $0.title = "Item \(index)"
            }
            items.append(newObject)
        }
        return items
    }
    
    @discardableResult
    func createTestEntityIntObjects(count: Int) -> [TestEntityInt] {
        var items: [TestEntityInt] = []
        let toAdd = lastIndex + 1
        for index in 0..<count {
            let id = Int32(index) + toAdd
            lastIndex = id
            let newObject = TestEntityInt.insertObject(with: id, in: viewContext) {
                $0.title = "Item \(index)"
            }
            items.append(newObject)
        }
        return items
    }
    
    @discardableResult
    func createTestEntityUUIDObjects(count: Int) -> [TestEntityUUID] {
        var items: [TestEntityUUID] = []
        for index in 0..<count {
            let id = UUID()
            let newObject = TestEntityUUID.insertObject(with: id, in: viewContext) {
                $0.title = "Item \(index)"
            }
            items.append(newObject)
        }
        return items
    }
}
