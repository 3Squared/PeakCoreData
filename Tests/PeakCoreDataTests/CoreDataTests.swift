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
    func createTestEntityJSONObjects(count: Int, test: (Int) -> Bool = { $0 % 2 == 0 }) -> [TestEntityJSON] {
        var intermediateItems: [TestEntityJSON] = []
        for index in 1...count {
            let id = UUID().uuidString
            let title = "Item \(index)"
            let intermediate = TestEntityJSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if test(index) {
                TestEntity.insertObject(with: id, in: viewContext)
            }
        }
        return intermediateItems
    }
    
    @discardableResult
    func createAnotherEntityJSONObjects(count: Int, test: (Int) -> Bool = { $0 % 2 == 0 }) -> [AnotherEntityJSON] {
        var intermediateItems: [AnotherEntityJSON] = []
        let toAdd = lastIndex + 1
        for index in 0..<count {
            let id = Int32(index) + toAdd
            lastIndex = id
            let title = "Item \(id)"
            let intermediate = AnotherEntityJSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if test(index) {
                AnotherEntity.insertObject(with: id, in: viewContext)
            }
        }
        return intermediateItems
    }
    
    @discardableResult
    func createTestEntityManagedObjects(count: Int) -> [TestEntity] {
        var items: [TestEntity] = []
        for index in 0..<count {
            let id = UUID().uuidString
            let newObject = TestEntity.insertObject(with: id, in: viewContext) {
                $0.title = "Item \(index)"
            }
            items.append(newObject)
        }
        return items
    }
    
    @discardableResult
    func createAnotherEntityManagedObjects(count: Int) -> [AnotherEntity] {
        var items: [AnotherEntity] = []
        let toAdd = lastIndex + 1
        for index in 0..<count {
            let id = Int32(index) + toAdd
            lastIndex = id
            let newObject = AnotherEntity.insertObject(with: id, in: viewContext) {
                $0.title = "Item \(index)"
            }
            items.append(newObject)
        }
        return items
    }
}
