//
//  Person.swift
//  PeakCoreDataExample
//
//  Created by Ben Walker on 16/07/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import PeakCoreData

extension Person {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        uniqueID = UUID().uuidString
    }
    
    static func predicate(forEventID eventID: String) -> NSPredicate {
        return NSPredicate(equalTo: eventID, keyPath: #keyPath(Person.event.uniqueID))
    }
}

extension Person: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sort1 = NSSortDescriptor(key: #keyPath(Person.name), ascending: true)
        return [sort1]
    }
}

extension Person: UniqueIdentifiable {
    
    public static var uniqueIDKey: String { #keyPath(Person.uniqueID) }
    public var uniqueIDValue: String { uniqueID! }
}

public struct PersonJSON: Codable {
    let uniqueID: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueID = "id"
        case name = "name"
    }
}

extension PersonJSON: ManagedObjectUpdatable {
    
    public typealias ManagedObject = Person
    
    public static var updateProperties: UpdatePropertiesBlock? = { intermediate, managedObject in
        managedObject.uniqueID = intermediate.uniqueID
        managedObject.name = intermediate.name
    }
    
    public static var updateRelationships: UpdateRelationshipsBlock? = nil
}

extension PersonJSON: UniqueIdentifiable {
    
    public static var uniqueIDKey: String { "uniqueID" }
    public var uniqueIDValue: String { uniqueID }
}
