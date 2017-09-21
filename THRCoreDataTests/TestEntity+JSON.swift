//
//  TestEntity+JSON.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
@testable import THRCoreData

public struct TestEntityJSON: Decodable {
    let uniqueID: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case uniqueID = "id"
        case title = "title"
    }
}

extension TestEntity: Updatable {

    public func updateProperties(with json: TestEntityJSON) {
        uniqueID = json.uniqueID
        title = json.title
    }
    
    public func updateRelationships(with json: TestEntityJSON) {
        
    }
}

extension TestEntityJSON: UniqueIdentifiable {
    
    public static var uniqueIDKey: String {
        return "uniqueID"
    }
    
    public var uniqueIDValue: String {
        return uniqueID
    }
}
