//
//  TestEntityUUID+JSON.swift
//  PeakCoreDataTests
//
//  Created by David Yates on 09/07/2021.
//  Copyright © 2021 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
@testable import PeakCoreData

public struct TestEntityUUIDJSON: Codable {
    let uniqueID: UUID
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueID = "id"
        case title = "title"
    }
}

extension TestEntityUUIDJSON: ManagedObjectUpdatable {
    
    public typealias ManagedObject = TestEntityUUID
    
    public static var updateProperties: UpdatePropertiesBlock? = { intermediate, managedObject in
        managedObject.title = intermediate.title
    }
    
    public static var updateRelationships: UpdateRelationshipsBlock? = nil
}

extension TestEntityUUIDJSON: ManagedObjectInitialisable {
    
    public init(with managedObject: TestEntityUUID) throws {
        uniqueID = managedObject.uniqueIDValue
        title = managedObject.title!
    }
}

extension TestEntityUUIDJSON: UniqueIdentifiable {
    public static var uniqueIDKey: String { "uniqueID" }
    public var uniqueIDValue: UUID { uniqueID }
}

