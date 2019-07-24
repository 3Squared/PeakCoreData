//
//  ProgressTests.swift
//  PeakCoreDataTests
//
//  Created by Sam Oakley on 15/04/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

class ProgressTests: CoreDataTests {

    func testBatchImportOperation() {
        // Create intermediate objects
        let input = CoreDataTests.createTestIntermediateObjects(number: 100, in: viewContext)
        try! viewContext.save()
        
        // Create import operation with intermediates as input
        let operation = CoreDataBatchImportOperation<TestEntityJSON>(with: persistentContainer)
        operation.input = Result { input }
        
        let progress = operation.chainProgress()
        
        keyValueObservingExpectation(for: progress, keyPath: "fractionCompleted") {  observedObject, change in
            return progress.completedUnitCount == progress.totalUnitCount
        }

        operation.enqueue()
        waitForExpectations(timeout: defaultTimeout)
    }
}
