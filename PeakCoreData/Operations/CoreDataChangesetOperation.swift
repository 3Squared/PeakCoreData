//
//  CoreDataChangesetOperation.swift
//  PeakCoreData
//
//  Created by David Yates on 12/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakOperation

open class CoreDataChangesetOperation: CoreDataOperation<Changeset> {
    
    open override func saveAndFinish() {
        guard !isCancelled else { return finish() }
        saveOperationContext()
        output = Result { return Changeset(inserted: inserted, updated: updated) }
        finish()
    }
}
