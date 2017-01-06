//
//  ImportManyOperation.swift
//  THRCoreData
//
//  Created by Ben Walker on 15/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import THROperations
import THRNetwork

open class ImportManyOperation<J, M>: CoreDataOperation where J: JSONConvertible, J: UniqueIdentifiable, M: NSManagedObject, M: ManagedObjectType, M: UniqueIdentifiable, M: Updatable {
    
    override open func performWork(inContext context: NSManagedObjectContext) {
        defer { completeAndSave() }
        
        // Bad way to restore some type safety
        if J.self != M.T.self { fatalError() }
        
        guard let previous = dependencies.last as? ResultOperation<[J]> else { return }
        
        do {
            let intermediates = try previous.result().resolve()
            
            M.insertOrUpdate(intermediates: intermediates, inContext: context) { intermediate, model in
                model.updateProperties(with: intermediate as! M.T)
            }
        } catch {
            print(error)
        }
    }
}
