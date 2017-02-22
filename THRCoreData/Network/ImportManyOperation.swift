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
import THRResult

open class ImportManyOperation<J, M>: CoreDataOperation, ConsumesResult where J: JSONConvertible, J: UniqueIdentifiable, M: NSManagedObject, M: ManagedObjectType, M: UniqueIdentifiable, M: Updatable {
    
    public var input: Result<[J]> = Result { throw ResultError.noResult }

    override open func performWork(inContext context: NSManagedObjectContext) {
        defer { completeAndSave() }
        
        // Bad way to restore some type safety
        if J.self != M.T.self { fatalError() }
        
        do {
            let intermediates = try input.resolve()
            
            M.insertOrUpdate(intermediates: intermediates, inContext: context) { intermediate, model in
                model.updateProperties(with: intermediate as! M.T)
            }
        } catch {
            print(error)
        }
    }
}
