//
//  Updatable.swift
//  PeakCoreData
//
//  Created by Sam Oakley on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData

public protocol ManagedObjectUpdatable: UniqueIdentifiable where UniqueIDType == ManagedObject.UniqueIDType {
    associatedtype ManagedObject: ManagedObjectType & UniqueIdentifiable
    
    typealias UpdatePropertiesBlock = ((Self, ManagedObject) -> Void)
    typealias UpdateRelationshipsBlock = ((Self, ManagedObject, NSManagedObjectContext, ManagedObjectCache?) -> Void)
    
    static var updateProperties: UpdatePropertiesBlock? { get }
    static var updateRelationships: UpdateRelationshipsBlock? { get }
}

public extension ManagedObjectUpdatable {
    static var hasProperties: Bool { updateProperties != nil }
    static var hasRelationships: Bool { updateRelationships != nil }
}
