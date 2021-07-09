//
//  TestEntityInt+JSON.swift
//  PeakCoreData
//
//  Created by David Yates on 08/07/2021.
//  Copyright © 2021 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
@testable import PeakCoreData

public struct TestEntityIntJSON: Codable {
    let uniqueID: Int32
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueID = "id"
        case title = "title"
    }
}

extension TestEntityIntJSON: ManagedObjectUpdatable {
    
    public typealias ManagedObject = TestEntityInt
    
    public static var updateProperties: UpdatePropertiesBlock? = { intermediate, managedObject in
        managedObject.title = intermediate.title
    }
    
    public static var updateRelationships: UpdateRelationshipsBlock? = nil
}

extension TestEntityIntJSON: ManagedObjectInitialisable {
    
    public init(with managedObject: TestEntityInt) throws {
        uniqueID = managedObject.uniqueIDValue
        title = managedObject.title!
    }
}

extension TestEntityIntJSON: UniqueIdentifiable {
    public static var uniqueIDKey: String { "uniqueID" }
    public var uniqueIDValue: Int32 { uniqueID }
}

