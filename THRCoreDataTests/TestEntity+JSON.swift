//
//  TestEntity+JSON.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
@testable import THRCoreData

extension TestEntity {
    
    struct JSON {
        let uniqueID: String
        let title: String
    }
}

extension TestEntity.JSON: UniqueIdentifiable {
    
    static var uniqueIDKey: String {
        return "uniqueID"
    }
    
    var uniqueIDValue: String {
        return uniqueID
    }
}
