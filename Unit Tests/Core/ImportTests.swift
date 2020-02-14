//
//  ImportTests.swift
//  PeakCoreData-iOSTests
//
//  Created by David Yates on 14/02/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

class ImportTests: CoreDataTests {

    var operationQueue: OperationQueue {
        let queue = OperationQueue()
        return queue
    }
    
    func testImportToCoreData() {
        
        let intermediates = loadJson(filename: "CompetencyCriteria")
                
        measure {
            let context = NSManagedObjectContext.testingInMemoryContext()
            context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
            let cache: ManagedObjectCache? = ManagedObjectCache()
            
            // Risk Levels
            
            let riskLevels = Set(intermediates.map { $0.competencyCriteriaRiskLevelId })
            CompetencyCriteriaRiskLevel.fetchOrInsertObjects(with: riskLevels, in: context, with: cache)
            
            // Competency Elements
            
            let competencyElements = Set(intermediates.map { $0.competencyElementId })
            CompetencyElement.fetchOrInsertObjects(with: competencyElements, in: context, with: cache)
            
            // Base Competency Criteria
            
            let baseCompetencyCriteria = Set(intermediates.map { $0.referenceId })
            BaseCompetencyCriteria.fetchOrInsertObjects(with: baseCompetencyCriteria, in: context, with: cache)
            
            // Competency Cycles
            
            let competencyCycles = Set(intermediates.compactMap { $0.competencyCycles }.flatMap { $0 })
            let competencyCycleIDs = Set(competencyCycles.map { $0.uniqueIDValue })
            CompetencyCycle.fetchOrInsertObjects(with: competencyCycleIDs, in: context, with: cache)
            
            intermediates.forEach { intermediate in
                let managedObject = CompetencyCriteria.fetchOrInsertObject(with: intermediate.uniqueIDValue, in: context, with: cache)
                
                CompetencyCriteriaJSON.updateProperties?(intermediate, managedObject)
                
                managedObject.baseCompetencyCriteria = BaseCompetencyCriteria.fetchOrInsertObject(with: intermediate.referenceId, in: context, with: cache)
                
                managedObject.competencyElement = CompetencyElement.fetchOrInsertObject(with: intermediate.competencyElementId, in: context, with: cache)
                
                managedObject.competencyCriteriaRiskLevel = CompetencyCriteriaRiskLevel.fetchOrInsertObject(with: intermediate.competencyCriteriaRiskLevelId, in: context, with: cache)
                
                if let competencyCycles = intermediate.competencyCycles {
                    let mos: [CompetencyCycle] = competencyCycles.compactMap { CompetencyCycle.fetchOrInsertObject(with: $0.competencyCycleId, in: context, with: cache) }
                    managedObject.addToCompetencyCycles(NSSet(array: mos))
                }
            }
            
            do {
                try context.save()
                XCTAssertEqual(CompetencyCriteria.count(in: context), intermediates.count)
                XCTAssertEqual(CompetencyCriteriaRiskLevel.count(in: context), riskLevels.count)
                XCTAssertEqual(CompetencyElement.count(in: context), competencyElements.count)
                XCTAssertEqual(BaseCompetencyCriteria.count(in: context), baseCompetencyCriteria.count)
                XCTAssertEqual(CompetencyCycle.count(in: context), competencyCycles.count)
            } catch {
                XCTFail()
            }
        }
    }
    
    func testImportWithOperation() {
        let intermediates = loadJson(filename: "CompetencyCriteria")
        
        let finishExpectation = expectation(description: #function)
        
        let cache: ManagedObjectCache = ManagedObjectCache()
        
        let operation = CoreDataImportOperation<CompetencyCriteriaJSON>(cache: cache, persistentContainer: persistentContainer)
        operation.input = Result.success(intermediates)

        operation.enqueue(on: operationQueue) { result in
            switch result {
            case .success(let changeset):
                let inserted = changeset.inserted(of: CompetencyCriteria.self)
                let updated = changeset.updated(of: CompetencyCriteria.self)
                XCTAssertEqual(inserted.count + updated.count, intermediates.count)
            case .failure(let error):
                print(error)
                XCTFail()
            }
            finishExpectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }
    
    func loadJson(filename fileName: String) -> [CompetencyCriteriaJSON] {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: fileName, withExtension: "json")!
        
        do {
            let data = try Data(contentsOf: url)
            let jsonData = try JSONDecoder.default.decode([CompetencyCriteriaJSON].self, from: data)
            return jsonData
        } catch {
            print("error:\(error)")
            return []
        }
    }
}

extension JSONDecoder {
    
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.custom(CodableStrategy.lowerCamelCase)
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom { (decoder) -> Date in
            let dateString = try! decoder.singleValueContainer().decode(String.self)
            let onlyNumbers = String(dateString.filter { "0123456789".contains($0) })
            let milliSeconds = Double(onlyNumbers)!
            return Date(timeIntervalSince1970: milliSeconds/1000.0)
        }
        return decoder
    }()
}

/// An implementation of CodingKey that's useful for combining and transforming keys as strings.
struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension Array where Element == CodingKey {
    var lastComponent: String {
        return String(last!.stringValue.split(separator: ".").last!)
    }
}

extension String {
    
    public func capitalisingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    public func lowercasingFirstLetter() -> String {
        let first = String(prefix(1)).lowercased()
        let other = String(dropFirst())
        return first + other
    }
}

public final class CodableStrategy {
    
    public static let lowerCamelCase: (([CodingKey]) -> CodingKey) = { keys in
        let lastComponent = keys.lastComponent.lowercasingFirstLetter()
        return AnyKey(stringValue: lastComponent)!
    }
    
    public static let upperCamelCase: (([CodingKey]) -> CodingKey) = { keys in
        let lastComponent = keys.lastComponent.capitalisingFirstLetter()
        return AnyKey(stringValue: lastComponent)!
    }
}
