//
//  AnotherEntity+JSON.swift
//  PeakCoreData
//
//  Created by David Yates on 08/07/2021.
//  Copyright © 2021 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
@testable import PeakCoreData

public struct AnotherEntityJSON: Codable {
    let uniqueID: Int32
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueID = "id"
        case title = "title"
    }
}

extension AnotherEntityJSON: ManagedObjectUpdatable {
    
    public typealias ManagedObject = AnotherEntity
    
    public static var updateProperties: UpdatePropertiesBlock? = { intermediate, managedObject in
        managedObject.title = intermediate.title
    }
    
    public static var updateRelationships: UpdateRelationshipsBlock? = nil
}

extension AnotherEntityJSON: ManagedObjectInitialisable {
    
    public init(with managedObject: AnotherEntity) throws {
        uniqueID = managedObject.uniqueIDValue
        title = managedObject.title!
    }
}

extension AnotherEntityJSON: UniqueIdentifiable {
    public static var uniqueIDKey: String { "uniqueID" }
    public var uniqueIDValue: Int32 { uniqueID }
}

