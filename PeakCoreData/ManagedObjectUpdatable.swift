//
//  Updatable.swift
//  PeakCoreData
//
//  Created by Sam Oakley on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public protocol ManagedObjectUpdatable {
    associatedtype ManagedObject: NSManagedObject
    func updateProperties(on managedObject: ManagedObject)
    func updateRelationships(on managedObject: ManagedObject, in context: NSManagedObjectContext)
}

public protocol ManagedObjectInitialisable {
    associatedtype ManagedObject: NSManagedObject
    init(with managedObject: ManagedObject) throws
}

public extension ManagedObjectType where Self: NSManagedObject {
    func encode<T>(to type: T.Type, encoder: JSONEncoder) throws -> Data where T: ManagedObjectInitialisable & Codable, T.ManagedObject == Self {
        return try encoder.encode(T(with: self))
    }
}
