//
//  Updatable.swift
//  GitHubbed
//
//  Created by Sam Oakley on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import THRNetwork

protocol Updatable {
    associatedtype T: JSONConvertible
    func updateProperties(with json: T)
}
