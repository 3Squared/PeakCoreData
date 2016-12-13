//
//  Utilities.swift
//  THRCoreData
//
//  Created by David Yates on 08/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation

internal var defaultDirectoryURL: URL {
    do {
        let searchPathDirectory = FileManager.SearchPathDirectory.documentDirectory
        return try FileManager.default.url(for: searchPathDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true)
    } catch {
        fatalError("Error finding default directory: \(error)")
    }
}

public enum SaveResult: Equatable {
    case success
    case failure(NSError)
    
    public func error() -> NSError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}

public func ==(lhs: SaveResult, rhs: SaveResult) -> Bool {
    switch (lhs, rhs) {
    case (.success, .success):
        return true
        
    case (let .failure(error1), let .failure(error2)):
        return error1 == error2
        
    default:
        return false
    }
}
