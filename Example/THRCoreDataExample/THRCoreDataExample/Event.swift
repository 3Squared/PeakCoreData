//
//  Event.swift
//  THRCoreDataExample
//
//  Created by David Yates on 21/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import THRCoreData

extension Event {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        uniqueID = UUID().uuidString
    }
}

extension Event: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sort1 = NSSortDescriptor(key: #keyPath(Event.date), ascending: true)
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
