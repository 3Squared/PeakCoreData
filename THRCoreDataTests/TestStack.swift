//
//  TestStack.swift
//  THRCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest

class TestStack: TestCase {
    
    func test_MainContext() {
        let mainContext = coreDataManager.mainContext
        XCTAssertNotNil(mainContext, "")
        XCTAssertEqual(mainContext.concurrencyType, .mainQueueConcurrencyType, "")
    }
    
    func test_BackgroundContext() {
        let backgroundContext = coreDataManager.backgroundContext
        XCTAssertNotNil(backgroundContext, "")
        XCTAssertEqual(backgroundContext.concurrencyType, .privateQueueConcurrencyType, "")
    }
    
    func test_SamePersistentStoreCoordinator() {
        let mainContext = coreDataManager.mainContext
        let backgroundContext = coreDataManager.backgroundContext
        XCTAssertEqual(mainContext.persistentStoreCoordinator, backgroundContext.persistentStoreCoordinator, "")
    }
    
    func test_SingleStore() {
        let mainContext = coreDataManager.mainContext
        XCTAssertTrue(mainContext.persistentStoreCoordinator!.persistentStores.count == 1, "")
    }
    
    func test_InsertAndSave_InMainContext() {
        
        // GIVEN: objects in the main context
        
        let mainContext = coreDataManager.mainContext
        let entities = self.createTestObjects(inContext: mainContext, count: 10)
        let titles = entities.map { $0.title! }
        
        // WHEN: we save the main context
        
        coreDataManager.save(context: mainContext)
        
        // WHEN: we fetch the objects in the main context
        
        let fetchRequest = TestEntity.sortedFetchRequest()
        var results: [TestEntity] = []
        mainContext.performAndWait {
            results = try! mainContext.fetch(fetchRequest)
        }
        
        // THEN: the main context returns the objects
        
        XCTAssertEqual(results.count, entities.count, "Main context should return same objects")
        results.forEach { (testEntity: TestEntity) in
            XCTAssertTrue(titles.contains(testEntity.title!), "Main context should return same objects")
        }
    }
    
    func test_InsertAndSave_InBackgroundContext() {
        
        // GIVEN: objects in the background context
        
        let backgroundContext = coreDataManager.backgroundContext
        let entities = self.createTestObjects(inContext: backgroundContext, count: 10)
        let titles = entities.map { $0.title! }
        
        // WHEN: we save the background context
        
        coreDataManager.save(context: backgroundContext)
        
        // WHEN: we fetch the objects in the background context
        
        let fetchRequest = TestEntity.sortedFetchRequest()
        var results: [TestEntity] = []
        backgroundContext.performAndWait {
            results = try! backgroundContext.fetch(fetchRequest)
        }
        
        // THEN: the background context returns the objects
        
        XCTAssertEqual(results.count, entities.count, "Background context should return same objects")
        results.forEach { (testEntity: TestEntity) in
            XCTAssertTrue(titles.contains(testEntity.title!), "Background context should return same objects")
        }
    }
    
    func test_ThatChangesPropogate_FromBackgroundContext_ToMainContext() {
        
        // GIVEN: objects in the background context
        
        let backgroundContext = coreDataManager.backgroundContext
        let entities = self.createTestObjects(inContext: backgroundContext, count: 10)
        let titles = entities.map { $0.title! }
        
        // WHEN: we save the background context
        
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: backgroundContext, handler: nil)
        
        coreDataManager.save(context: backgroundContext)
        
        waitForExpectations(timeout: 1.0) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }
        
        // WHEN: we fetch the objects in the main context
        
        let mainContext = coreDataManager.mainContext
        
        let fetchRequest = TestEntity.sortedFetchRequest()
        var results: [TestEntity] = []
        mainContext.performAndWait {
            results = try! mainContext.fetch(fetchRequest)
        }
        
        // THEN: the main context returns the objects
        
        XCTAssertEqual(results.count, entities.count, "Main context should return same objects")
        results.forEach { (testEntity: TestEntity) in
            XCTAssertTrue(titles.contains(testEntity.title!), "Main context should return same objects")
        }
    }
    
    func test_ThatChangesPropogate_FromMainContext_ToBackgroundContext() {
        
        // GIVEN: objects in the main context
        
        let mainContext = coreDataManager.mainContext
        let entities = self.createTestObjects(inContext: mainContext, count: 10)
        let titles = entities.map { $0.title! }
        
        // WHEN: we save the main context
        
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: mainContext, handler: nil)
        
        coreDataManager.save(context: mainContext)
        
        waitForExpectations(timeout: 1.0) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }
        
        // WHEN: we fetch the objects in the background context
        
        let backgroundContext = coreDataManager.backgroundContext
        
        let fetchRequest = TestEntity.sortedFetchRequest()
        var results: [TestEntity] = []
        backgroundContext.performAndWait {
            results = try! backgroundContext.fetch(fetchRequest)
        }
        
        // THEN: the background context returns the objects
        
        XCTAssertEqual(results.count, entities.count, "Background context should return same objects")
        results.forEach { (testEntity: TestEntity) in
            XCTAssertTrue(titles.contains(testEntity.title!), "Background context should return same objects")
        }
    }
    
    func test_ThatChangesPropogate_FromChildOfMainContext_ToMainContext() {
        
        // GIVEN: objects in the child of the main context
        
        let childContext = self.coreDataManager.createChildContext(withConcurrencyType: .mainQueueConcurrencyType)
        let entities = self.createTestObjects(inContext: childContext, count: 10)
        let titles = entities.map { $0.title! }
        
        // WHEN: we save the child of the main context
        
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext, handler: nil)
        
        coreDataManager.save(context: childContext)
        
        waitForExpectations(timeout: 1.0) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }
        
        // WHEN: we fetch the objects in the main context
        
        let mainContext = coreDataManager.mainContext
        
        let fetchRequest = TestEntity.sortedFetchRequest()
        var results: [TestEntity] = []
        mainContext.performAndWait {
            results = try! mainContext.fetch(fetchRequest)
        }
        
        // THEN: the main context returns the objects
        
        XCTAssertEqual(results.count, entities.count, "Main context should return same objects")
        results.forEach { (testEntity: TestEntity) in
            XCTAssertTrue(titles.contains(testEntity.title!), "Main context should return same objects")
        }
    }
    
    func test_ThatChangesPropogate_FromChildOfMainContext_ToBackgroundContext() {
        
        // GIVEN: objects in the child of the main context
        
        let childContext = self.coreDataManager.createChildContext(withConcurrencyType: .mainQueueConcurrencyType)
        let entities = self.createTestObjects(inContext: childContext, count: 10)
        let titles = entities.map { $0.title! }
        
        // WHEN: we save the child of the main context
        
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext, handler: nil)
        
        coreDataManager.save(context: childContext)
        
        waitForExpectations(timeout: 1.0) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }
        
        // WHEN: we fetch the objects in the background context
        
        let backgroundContext = coreDataManager.mainContext
        
        let fetchRequest = TestEntity.sortedFetchRequest()
        var results: [TestEntity] = []
        backgroundContext.performAndWait {
            results = try! backgroundContext.fetch(fetchRequest)
        }
        
        // THEN: the background context returns the objects
        
        XCTAssertEqual(results.count, entities.count, "Main context should return same objects")
        results.forEach { (testEntity: TestEntity) in
            XCTAssertTrue(titles.contains(testEntity.title!), "Main context should return same objects")
        }
    }
    
    func test_ThatChangesPropogate_FromChildOfBackgroundContext_ToBackgroundContext() {
        
        // GIVEN: objects in the child of the background context
        
        let childContext = self.coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        let entities = self.createTestObjects(inContext: childContext, count: 10)
        let titles = entities.map { $0.title! }
        
        // WHEN: we save the child of the background context
        
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext, handler: nil)
        
        coreDataManager.save(context: childContext)
        
        waitForExpectations(timeout: 1.0) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }
        
        // WHEN: we fetch the objects in the background context
        
        let backgroundContext = coreDataManager.backgroundContext
        
        let fetchRequest = TestEntity.sortedFetchRequest()
        var results: [TestEntity] = []
        backgroundContext.performAndWait {
            results = try! backgroundContext.fetch(fetchRequest)
        }
        
        // THEN: the background context returns the objects
        
        XCTAssertEqual(results.count, entities.count, "Background context should return same objects")
        results.forEach { (testEntity: TestEntity) in
            XCTAssertTrue(titles.contains(testEntity.title!), "Background context should return same objects")
        }
    }
    
    func test_ThatChangesPropogate_FromChildOfBackgroundContext_ToMainContext() {
        
        // GIVEN: objects in the child of the background context
        
        let childContext = self.coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        let entities = self.createTestObjects(inContext: childContext, count: 10)
        let titles = entities.map { $0.title! }
        
        // WHEN: we save the child of the background context
        
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext, handler: nil)
        
        coreDataManager.save(context: childContext)
        
        waitForExpectations(timeout: 1.0) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }
        
        // WHEN: we fetch the objects in the main context
        
        let mainContext = coreDataManager.mainContext
        
        let fetchRequest = TestEntity.sortedFetchRequest()
        var results: [TestEntity] = []
        mainContext.performAndWait {
            results = try! mainContext.fetch(fetchRequest)
        }
        
        // THEN: the main context returns the objects
        
        XCTAssertEqual(results.count, entities.count, "Main context should return same objects")
        results.forEach { (testEntity: TestEntity) in
            XCTAssertTrue(titles.contains(testEntity.title!), "Main context should return same objects")
        }
    }

    func testChildContextChangesAreOnlyPushedOnSave() {
        
        // GIVEN: objects in the child of the background context
        
        let childContext = self.coreDataManager.createChildContext(withConcurrencyType: .privateQueueConcurrencyType)
        self.createTestObjects(inContext: childContext, count: 10)
        
        // WHEN: we do not save the child context
        
        // THEN: the background context does not return the objects
        
        let count = TestEntity.count(inContext: coreDataManager.backgroundContext)
        XCTAssertTrue(count == 0, "\(count)")
    }
}
