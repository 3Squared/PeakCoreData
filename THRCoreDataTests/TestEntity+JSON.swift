//
//  TestEntity+JSON.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
@testable import THRCoreData
import THRNetwork

extension TestEntity: Updatable {
    
    public struct JSON: JSONConvertible {
        let uniqueID: String
        let title: String
        
        public init(fromJson json: JSONObject) throws {
            uniqueID = json["id"] as! String
            title = json["title"] as! String
        }
    }
    
    public func updateProperties(with json: TestEntity.JSON) {
        
    }
}

extension TestEntity.JSON: UniqueIdentifiable {
    
    public static var uniqueIDKey: String {
        return "uniqueID"
    }
    
    public var uniqueIDValue: String {
        return uniqueID
    }
}
