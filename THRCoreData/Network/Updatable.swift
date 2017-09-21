//
//  Updatable.swift
//  THRCoreData
//
//  Created by Sam Oakley on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation

public protocol Updatable {
    associatedtype JSONRepresentation: Decodable
    func updateProperties(with json: JSONRepresentation)
    func updateRelationships(with json: JSONRepresentation)
}
