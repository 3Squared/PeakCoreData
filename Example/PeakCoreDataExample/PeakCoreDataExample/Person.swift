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
}

extension Person: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sort1 = NSSortDescriptor(key: #keyPath(Person.name), ascending: false)
        return [sort1]
    }
}

extension Person: UniqueIdentifiable {
    
    public static var uniqueIDKey: String {
        return #keyPath(Person.uniqueID)
    }
    
    public var uniqueIDValue: String {
        return uniqueID!
    }
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
    
    public func updateProperties(on managedObject: Person) {
        managedObject.uniqueID = uniqueID
        managedObject.name = name
    }
    
    public func updateRelationships(on managedObject: Person, in context: NSManagedObjectContext) {
        //
    }
}

extension PersonJSON: UniqueIdentifiable {
    
    public static var uniqueIDKey: String {
        return "uniqueID"
    }
    
    public var uniqueIDValue: String {
        return uniqueID
    }
}
