//
//  FetchedCollectionTests.swift
//  PeakCoreDataTests
//
//  Created by Sam Oakley on 19/01/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import PeakCoreData

class FetchedCollectionTests: CoreDataTests {
    
    func createFetchedCollection() -> FetchedCollection<TestEntityString> {
        return FetchedCollection<TestEntityString>(fetchRequest: TestEntityString.sortedFetchRequest(), context: viewContext)
    }
    
    func createSectionedFetchedCollection() -> FetchedCollection<TestEntityString> {
        return FetchedCollection<TestEntityString>(fetchRequest: TestEntityString.sortedFetchRequest(), context: viewContext, sectionNameKeyPath: #keyPath(TestEntityString.uniqueID))
    }
    
    func testSnapshotIsStatic() {
        createTestEntityStringObjects(count: 10)

        let expect = expectation(description: "")
        
        let fetchedCollection = createFetchedCollection()
        
        fetchedCollection.onChange = { _, update in
            if update != nil { expect.fulfill() }
        }
        
        let snap = fetchedCollection.snapshot()

        XCTAssertEqual(fetchedCollection.count, 10)
        XCTAssertEqual(snap.count, 10)

        viewContext.performAndWait {
            self.viewContext.delete(fetchedCollection[0, 0])
        }

        waitForExpectations(timeout: defaultTimeout)

        XCTAssertEqual(fetchedCollection.count, 9)
        XCTAssertEqual(snap.count, 10)
    }

    func testSectionedResults() {
        createTestEntityStringObjects(count: 10)

        let sectionedFetchedCollection = createSectionedFetchedCollection()
        
        XCTAssertEqual(sectionedFetchedCollection.sections.count, 10)

        sectionedFetchedCollection.sections.forEach { section in
            XCTAssertEqual(section.numberOfObjects, 1)
        }
     }
    
    func testEmptySectionedResults() {
        let sectionedFetchedCollection = createSectionedFetchedCollection()
        XCTAssertEqual(sectionedFetchedCollection.sections.count, 0)
    }
    
    func testInsertChanges() {
        let expect = expectation(description: "")
        
        let fetchedCollection = createFetchedCollection()
        
        fetchedCollection.onChange = { objects, changes in
            guard let changes = changes else { return }
            
            XCTAssertEqual(objects.count, 10)
            
            changes.forEach { update in
                switch update {
                case .insert(at: _):
                    break
                default:
                    XCTFail()
                }
            }
            
            expect.fulfill()
        }

        viewContext.perform {
            self.createTestEntityStringObjects(count: 10)
            try! self.viewContext.save()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func testInsertSectionChanges() {
        createTestEntityStringObjects(count: 1)
        try! viewContext.save()

        let sectionedFetchedCollection = createSectionedFetchedCollection()

        XCTAssertEqual(sectionedFetchedCollection.sections.count, 1)

        viewContext.performAndWait {
            createTestEntityStringObjects(count: 1)
            try! self.viewContext.save()
        }

        XCTAssertEqual(sectionedFetchedCollection.sections.count, 2)

        sectionedFetchedCollection.sections.forEach { section in
            XCTAssertEqual(section.numberOfObjects, 1)
        }
    }

    func testDeletionChanges() {
        let expect = expectation(description: "")
        let inserted = createTestEntityStringObjects(count: 10)
        viewContext.perform {
            try! self.viewContext.save()
        }
        
        let fetchedCollection = createFetchedCollection()

        fetchedCollection.onChange = { objects, changes in
            if changes == nil {
                XCTAssertEqual(objects.count, 10)
                return
            }

            XCTAssertEqual(objects.count, 9)
            XCTAssertEqual(changes!.count, 1)

            switch changes![0] {
            case .delete(at: _):
                break
            default:
                XCTFail()
            }

            expect.fulfill()
        }

        let thing = inserted[0]
        viewContext.perform {
            self.viewContext.delete(thing)
            try! self.viewContext.save()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func testUpdateChanges() {
        let expect = expectation(description: "")
        let inserted = createTestEntityStringObjects(count: 10)
        viewContext.perform {
            try! self.viewContext.save()
        }
        
        let fetchedCollection = createFetchedCollection()

        fetchedCollection.onChange = { objects, changes in
            if changes == nil {
                XCTAssertEqual(objects.count, 10)
                return
            }

            XCTAssertEqual(objects.count, 10)
            XCTAssertEqual(changes!.count, 1)

            switch changes![0] {
            case .update(_, let object):
                XCTAssertEqual(object.uniqueID!, "what")
                break
            case .move(_, _): break
            default:
                XCTFail()
            }

            expect.fulfill()
        }

        let thing = inserted[0]
        viewContext.perform {
            thing.uniqueID = "what"
            try! self.viewContext.save()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func testMoveChanges() {
        let expect = expectation(description: "")
        let inserted = createTestEntityStringObjects(count: 10)
        
        let fetchedCollection = createFetchedCollection()
        
        fetchedCollection.onChange = { objects, changes in
            if changes == nil {
                XCTAssertEqual(objects.count, 10)
                return
            }

            XCTAssertEqual(objects.count, 10)
            // Move also calls update, so we should have two changes here
            XCTAssertEqual(changes!.count, 2)

            expect.fulfill()
        }

        let thing = inserted[0]
        viewContext.perform {
            thing.title = "Z"
            try! self.viewContext.save()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func testReconfigureFetchRequest() {
        let expect = expectation(description: "")

        createTestEntityStringObjects(count: 9)
        
        let uniqueID = "testid"
        TestEntityString.insert(withID: uniqueID, context: viewContext)
        
        let fetchedCollection = createFetchedCollection()
        
        fetchedCollection.onChange = { objects, changes in
            if objects.count == 1 {
                let obj = objects[IndexPath(item: 0, section: 0)]
                XCTAssertEqual(obj.uniqueID!, uniqueID)
                expect.fulfill()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            fetchedCollection.reconfigureFetchRequest { fr in
                fr.predicate = NSPredicate(equalTo: uniqueID, keyPath: #keyPath(TestEntityString.uniqueID))
            }
        }

        waitForExpectations(timeout: defaultTimeout)
    }
}
