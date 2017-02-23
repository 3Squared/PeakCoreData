//
//  Updatable.swift
//  THRCoreData
//
//  Created by Sam Oakley on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import THRNetwork

public protocol Updatable {
    associatedtype JSONRepresentation: JSONConvertible
    func updateProperties(with json: JSONRepresentation)
}
