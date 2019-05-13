//
//  ModelVersion.swift
//  PeakCoreData
//
//  Created by David Yates on 10/05/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData

typealias StoreMetadata = [String: Any]

public protocol ModelVersion: Equatable, CaseIterable {
    static var current: Self { get }
    static var bundle: Bundle { get }
    static var subdirectory: String { get }
    var name: String { get }
    var nextVersion: Self? { get }
}

extension ModelVersion {
    static var bundle: Bundle { return .main }

    var nextVersion: Self? { return nil }
    
    var managedObjectModel: NSManagedObjectModel {
        let omoURL: URL?
        if #available(iOS 11, *) {
            // Optimized model file (faster to load)
            omoURL = Self.bundle.url(forResource: name, withExtension: "omo", subdirectory: Self.subdirectory)
        } else {
            omoURL = nil
        }
        let momURL = Self.bundle.url(forResource: name, withExtension: "mom", subdirectory: Self.subdirectory)
        guard let url = omoURL ?? momURL else { fatalError("Model version \(self) not found") }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Cannot open model at \(url)") }
        return model
    }
    
    static func compatibleVersion(for metadata: StoreMetadata) -> Self? {
        return allCases.first { $0.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) }
    }
}
