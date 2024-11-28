//
//  Event.swift
//  PeakCoreDataExample
//
//  Created by David Yates on 21/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import PeakCoreData

extension Event {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        uniqueID = UUID().uuidString
    }
}

extension Event: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sort1 = NSSortDescriptor(key: #keyPath(Event.date), ascending: false)
        return [sort1]
    }
}

extension Event: UniqueIdentifiable {
    
    public static var uniqueIDKey: String { #keyPath(Event.uniqueID) }
    
    public var uniqueIDValue: String { uniqueID! }
}

public struct EventJSON: Codable {
    let uniqueID: String
    let date: Date
    let attendees: [PersonJSON]
    
    enum CodingKeys: String, CodingKey {
        case uniqueID = "id"
        case date = "date"
        case attendees = "attendees"
    }
}

extension EventJSON: ManagedObjectUpdatable {
    
    public typealias ManagedObject = Event
    
    public static var updateProperties: UpdatePropertiesBlock? = { intermediate, managedObject in
        managedObject.uniqueID = intermediate.uniqueID
        managedObject.date = intermediate.date
    }
    
    public static var updateRelationships: UpdateRelationshipsBlock? = { intermediate, managedObject, context, cache in
        
        Person.insertOrUpdate(intermediates: intermediate.attendees, context: context) { (json, person) in
            PersonJSON.updateProperties?(json, person)
            managedObject.addToAttendees(person)
        }
    }
}

extension EventJSON: UniqueIdentifiable {
    
    public static var uniqueIDKey: String { "uniqueID" }
    public var uniqueIDValue: String { uniqueID }
}

extension EventJSON {
    static func generate(_ numberToGenerate: Int) -> [EventJSON] {
        return (0..<numberToGenerate).map { eventItem -> EventJSON in
            let id = UUID().uuidString
            let date = Date().addingTimeInterval(-Double(eventItem))
            let attendees = (1...Int.random(in: 1...50)).map { personItem -> PersonJSON in
                let id = UUID().uuidString
                let personString = personItem < 10 ? "0\(personItem)" : "\(personItem)"
                let name = "Attendee \(personString)"
                return PersonJSON(uniqueID: id, name: name)
            }
            return EventJSON(uniqueID: id, date: date, attendees: attendees)
        }
    }
}
