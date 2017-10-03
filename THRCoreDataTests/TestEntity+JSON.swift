//
//  TestEntity+JSON.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
@testable import THRCoreData

public struct TestEntityJSON: Codable {
    let uniqueID: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueID = "id"
        case title = "title"
    }
}

extension TestEntityJSON: ManagedObjectUpdatable {
    public func updateProperties(on managedObject: TestEntity) {
        managedObject.uniqueID = uniqueID
        managedObject.title = title
    }
    
    public func updateRelationships(on managedObject: TestEntity, withContext context: NSManagedObjectContext) {
        //
    }
}

extension TestEntityJSON: ManagedObjectInitialisable {
    public init?(withManagedObject object: TestEntity) throws {
        uniqueID = object.uniqueIDValue
        title = object.title!
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
