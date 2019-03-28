//
//  NSManagedObjectContext.swift
//  PeakCoreData
//
//  Created by David Yates on 28/03/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    typealias VoidBlock = () -> Void
    typealias VoidBlockBlock = (VoidBlock) -> Void
    
    /// Helper function for convincing the type checker that
    /// the rethrows invariant holds for performAndWait.
    ///
    /// - Source: https://github.com/apple/swift/blob/bb157a070ec6534e4b534456d208b03adc07704b/stdlib/public/SDK/Dispatch/Queue.swift#L228-L249
    /// - Source: https://oleb.net/blog/2018/02/performandwait/
    public func performAndWait<T>(_ block: () throws -> T) rethrows -> T {
        
        func _helper<T>(fn: VoidBlockBlock, execute work: () throws -> T, rescue: ((Error) throws -> (T))) rethrows -> T {
            var r: T?
            var e: Error?
            withoutActuallyEscaping(work) { _work in
                fn {
                    do {
                        r = try _work()
                    } catch {
                        e = error
                    }
                }
            }
            if let error = e {
                return try rescue(error)
            }
            guard let result = r else {
                fatalError("Failed to generate a result or throw error.")
            }
            return result
        }
        
        return try _helper(fn: performAndWait(_:), execute: block, rescue: { throw $0 } )
    }
}
