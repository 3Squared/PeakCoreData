//
//  TestCase.swift
//  PeakCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

let defaultTimeout = TimeInterval(2)

public protocol ModelVersion: Equatable {
    static var all: [Self] { get }
    static var current: Self { get }
    var name: String { get }
    var successor: Self? { get }
    var modelBundle: Bundle { get }
    var modelDirectoryName: String { get }
}


extension ModelVersion {

    public var successor: Self? { return nil }

    public init?(storeURL: URL) {
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil) else { return nil }
        let version = Self.all.first {
            $0.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        guard let result = version else { return nil }
        self = result
    }

    public func managedObjectModel() -> NSManagedObjectModel {
        let omoURL = modelBundle.url(forResource: name, withExtension: "omo", subdirectory: modelDirectoryName)
        let momURL = modelBundle.url(forResource: name, withExtension: "mom", subdirectory: modelDirectoryName)
        guard let url = omoURL ?? momURL else { fatalError("model version \(self) not found") }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("cannot open model at \(url)") }
        return model
    }
}

enum TestModelVersion: String {
    case Version1 = "TestModel"
}


extension TestModelVersion: ModelVersion {
    static var all: [TestModelVersion] { return [.Version1] }
    static var current: TestModelVersion { return .Version1 }

    var name: String { return rawValue }
    var modelBundle: Bundle { return Bundle(for: CoreDataTests.self) }
    var modelDirectoryName: String { return "TestModel.momd" }
}

extension NSManagedObjectContext {
    
    static func testingInMemoryContext() -> NSManagedObjectContext {
        return testContext { $0.addInMemoryTestStore() }
    }
    
    static func testingSQLiteContext() -> NSManagedObjectContext {
        return testContext { $0.addSQLiteTestStore() }
    }
    
    static func testContext(_ addStore: (NSPersistentStoreCoordinator) -> ()) -> NSManagedObjectContext {
        let model = TestModelVersion.current.managedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        addStore(coordinator)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
}

extension NSPersistentStoreCoordinator {
    
    func addInMemoryTestStore() {
        try! addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    }
    
    func addSQLiteTestStore() {
        let storeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("PeakCoreData-tests")
        if FileManager.default.fileExists(atPath: storeURL.path) {
            try! destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        }
        try! addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    }
}

class CoreDataTests: XCTestCase, PersistentContainerSettable {
    
    var persistentContainer: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        
        let testBundle = Bundle(for: type(of: self))
        let model = NSManagedObjectModel.mergedModel(from: [testBundle])
        persistentContainer = NSPersistentContainer(name: "TestModel", managedObjectModel: model!)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print(error)
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    override func tearDown() {
        persistentContainer = nil
        super.tearDown()
    }
    
    @discardableResult
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
    static func createTestEntityManagedObjects(in context: NSManagedObjectContext, count: Int) -> [TestEntity] {
        var items: [TestEntity] = []
        for item in 0..<count {
            let id = UUID().uuidString
            let newObject = TestEntity.insertObject(with: id, in: context)
            newObject.title = "Item " + String(item)
            items.append(newObject)
        }
        return items
    }
    
    @discardableResult
    static func createAnotherEntityManagedObjects(in context: NSManagedObjectContext, count: Int) -> [AnotherEntity] {
        var items: [AnotherEntity] = []
        for item in 0..<count {
            let id = UUID().uuidString
            let newObject = AnotherEntity.insertObject(with: id, in: context)
            newObject.title = "Item " + String(item)
            items.append(newObject)
        }
        return items
    }
}
