//
//  ImportOperation.swift
//  GitHubbed
//
//  Created by Ben Walker on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import THROperations
import CoreData
import THRNetwork

class ImportOperation<J, M>: CoreDataOperation where J: JSONConvertible, J: UniqueIdentifiable, M: NSManagedObject, M: ManagedObjectType, M: UniqueIdentifiable, M: Updatable {
    override func performWork(inContext context: NSManagedObjectContext) {
        defer { completeAndSave() }
        
        // Bad way to restore some type safety
        if J.self != M.T.self { fatalError() }
        
        guard let previous = dependencies.last as? ResultOperation<J> else { return }
        
        do {
            let intermediate = try previous.result().resolve()
            
            M.fetchOrInsertObject(withUniqueKeyValue: intermediate.uniqueIDValue, inContext: context) { model in
                model.updateProperties(with: intermediate as! M.T)
                print(model)
            }
        } catch {
            print(error)
        }
    }
}
