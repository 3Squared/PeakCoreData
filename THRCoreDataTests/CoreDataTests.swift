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
let modelName = "TestModel"

class CoreDataTests: XCTestCase, PersistentContainerSettable {
    
    var persistentContainer: PersistentContainer!
    var mainContext: NSManagedObjectContext {
        return persistentContainer.mainContext
    }
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: type(of: self))
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("*** Error loading model URL for model named \(modelName) in main bundle")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("*** Error loading managed object model at url: \(modelURL)")
        }
        persistentContainer = PersistentContainer(name: modelName, model: model)
        let storeURL = persistentContainer.defaultDirectoryURL().appendingPathComponent(modelName)
        
        var storeDescription = PersistentStoreDescription(url: storeURL)
        storeDescription.type = .inMemory        
        persistentContainer.persistentStoreDescription = storeDescription
        
        persistentContainer.loadPersistentStores()
    }
    
    override func tearDown() {
        persistentContainer = nil
        super.tearDown()
    }
    
    static func createTestIntermediateObjects(number: Int, inContext context: NSManagedObjectContext, test: (Int) -> Bool = { $0 % 2 == 0 }) -> [TestEntityJSON] {
        var intermediateItems: [TestEntityJSON] = []
        for item in 0..<number {
            let id = UUID().uuidString
            let title = "Item " + String(item)
            let intermediate = TestEntityJSON(uniqueID: id, title: title)
            intermediateItems.append(intermediate)
            
            // Create a managed object for half the items, to check that they are correctly updated
            
            if test(item) {
                TestEntity.insertObject(withUniqueKeyValue: id, inContext: context)
            }
        }
        return intermediateItems
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
