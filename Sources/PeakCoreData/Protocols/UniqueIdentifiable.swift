//
//  UniqueIdentifiable.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation

public protocol UniqueIdentifiable {
    associatedtype UniqueIDType: Hashable & CustomStringConvertible
    static var uniqueIDKey: String { get }
    var uniqueIDValue: UniqueIDType { get }
}
