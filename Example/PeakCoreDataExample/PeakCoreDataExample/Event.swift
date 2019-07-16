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
    
    public static var uniqueIDKey: String {
        return #keyPath(Event.uniqueID)
    }
    
    public var uniqueIDValue: String {
        return uniqueID!
    }
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
    
    public func updateProperties(on managedObject: Event) {
        managedObject.uniqueID = uniqueID
        managedObject.date = date
    }
    
    public func updateRelationships(on managedObject: Event, in context: NSManagedObjectContext) {
        Person.insertOrUpdate(intermediates: attendees, in: context) { (json, person) in
            json.updateProperties(on: person)
            person.addToEvents(managedObject)
        }
    }
}

extension EventJSON: UniqueIdentifiable {
    
    public static var uniqueIDKey: String {
        return "uniqueID"
    }
    
    public var uniqueIDValue: String {
        return uniqueID
    }
}

extension EventJSON {
    static func generate(_ numberToGenerate: Int) -> [EventJSON] {
        return (0..<numberToGenerate).map { eventItem -> EventJSON in
            let id = UUID().uuidString
            let date = Date().addingTimeInterval(-Double(eventItem))
            let attendees = (1...Int.random(in: 1...50)).map { personItem -> PersonJSON in
                let id = UUID().uuidString
                let name = "Attendee \(personItem)"
                return PersonJSON(uniqueID: id, name: name)
            }
            return EventJSON(uniqueID: id, date: date, attendees: attendees)
        }
    }
}
