//
//  FetchedUpdate.swift
//  THRCoreData
//
//  Created by David Yates on 07/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import Foundation

enum FetchedUpdate<Object> {
    case insert(IndexPath)
    case update(IndexPath, Object)
    case move(IndexPath, IndexPath)
    case delete(IndexPath)
    case insertSection(at: Int)
    case deleteSection(at: Int)
}
