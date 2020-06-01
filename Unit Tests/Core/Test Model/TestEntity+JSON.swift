//
//  TestEntity+JSON.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

public struct TestEntityJSON: Codable {
    let uniqueID: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueID = "id"
        case title = "title"
    }
}

extension TestEntityJSON: ManagedObjectUpdatable {
    
    public typealias ManagedObject = TestEntity
    
    public static var updateProperties: UpdatePropertiesBlock? = { intermediate, managedObject in
        managedObject.uniqueID = intermediate.uniqueID
        managedObject.title = intermediate.title
    }
    
    public static var updateRelationships: UpdateRelationshipsBlock? = nil
}

extension TestEntityJSON: ManagedObjectInitialisable {
    
    public init(with managedObject: TestEntity) throws {
        uniqueID = managedObject.uniqueIDValue
        title = managedObject.title!
    }
}

extension TestEntityJSON: UniqueIdentifiable {
    
    public static var uniqueIDKey: String {
        return "uniqueID"
    }
    
    public var uniqueIDValue: String {
        return uniqueID
    }
}
