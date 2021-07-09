//
//  TestEntityString+JSON.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
@testable import PeakCoreData

public struct TestEntityStringJSON: Codable {
    let uniqueID: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueID = "id"
        case title = "title"
    }
}

extension TestEntityStringJSON: ManagedObjectUpdatable {
    
    public typealias ManagedObject = TestEntityString
    
    public static var updateProperties: UpdatePropertiesBlock? = { intermediate, managedObject in
        managedObject.title = intermediate.title
    }
    
    public static var updateRelationships: UpdateRelationshipsBlock? = nil
}

extension TestEntityStringJSON: ManagedObjectInitialisable {
    
    public init(with managedObject: TestEntityString) throws {
        uniqueID = managedObject.uniqueIDValue
        title = managedObject.title!
    }
}

extension TestEntityStringJSON: UniqueIdentifiable {
    public static var uniqueIDKey: String { "uniqueID" }
    public var uniqueIDValue: String { uniqueID }
}
