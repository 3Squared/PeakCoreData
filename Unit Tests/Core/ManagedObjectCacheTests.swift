//
//  ManagedObjectCacheTests.swift
//  PeakCoreData
//
//  Created by David Yates on 02/04/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

class ManagedObjectCacheTests: CoreDataTests {
    
    func testRegisterCreatesPermanentIDs() throws {
        let insertNumber = 10
        let objects = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        XCTAssertEqual((objects.filter { $0.objectID.isTemporaryID }).count, insertNumber)
        
        managedObjectCache.register(objects, in: viewContext)
        
        XCTAssertEqual((objects.filter { $0.objectID.isTemporaryID }).count, 0)
    }
    
    func testRegister() throws {
        let insertNumber = 10
        let objects = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: insertNumber)
        
        managedObjectCache.register(objects, in: viewContext)
                
        objects.forEach { obj in
            let cached: TestEntity? = managedObjectCache.object(withUniqueID: obj.uniqueIDValue, in: viewContext)
            XCTAssertNotNil(cached)
        }
    }
}
