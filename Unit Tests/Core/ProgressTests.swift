//
//  ProgressTests.swift
//  PeakCoreDataTests
//
//  Created by Sam Oakley on 15/04/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

class ProgressTests: CoreDataTests {
    
    func testAnyHashable() {
        
        class Object: NSObject, UniqueIdentifiable {
            @objc let uniqueID: AnyHashable
            @objc let name = "Jeff"
            
            static var uniqueIDKey: String { "uniqueID" }
            var uniqueIDValue: AnyHashable { uniqueID }
            
            internal init(uniqueID: AnyHashable) {
                self.uniqueID = uniqueID
                super.init()
            }
        }
        
        let count = 100
        var objects: [Object] = []
        var ids: [AnyHashable] = []
        for index in 0..<count {
            let id = String(index)
            objects.append(Object(uniqueID: id))
            
            if index.isMultiple(of: 2) {
                ids.append(id)
            }
        }
        
        XCTAssertEqual(objects.count, count)
        
        let predicate = NSPredicate(isIncludedIn: ids, keyPath: Object.uniqueIDKey)
        let filtered = objects.filter { predicate.evaluate(with: $0) }
        XCTAssertEqual(filtered.count, count / 2)
    }

//    func testBatchImportOperation() {
//        // Create intermediate objects
//        let input = CoreDataTests.createTestIntermediateObjects(number: 100, in: viewContext)
//        try! viewContext.save()
//        
//        // Create import operation with intermediates as input
//        let operation = CoreDataBatchImportOperation<TestEntityJSON>(batchSize: 10_000, persistentContainer: persistentContainer)
//        operation.input = Result { input }
//        
//        let progress = operation.chainProgress()
//        
//        keyValueObservingExpectation(for: progress, keyPath: "fractionCompleted") {  observedObject, change in
//            return progress.completedUnitCount == progress.totalUnitCount
//        }
//
//        operation.enqueue()
//        waitForExpectations(timeout: defaultTimeout)
//    }
}
