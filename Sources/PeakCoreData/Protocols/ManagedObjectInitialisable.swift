//
//  ManagedObjectInitialisable.swift
//  PeakCoreData-iOS
//
//  Created by David Yates on 01/06/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import CoreData

public protocol ManagedObjectInitialisable {
    associatedtype ManagedObject: NSManagedObject
    init(with managedObject: ManagedObject) throws
}

public extension ManagedObjectType {
    
    func encode<T: ManagedObjectInitialisable & Codable>(to type: T.Type, encoder: JSONEncoder) throws -> Data where T.ManagedObject == Self {
        try encoder.encode(T(with: self))
    }
}
