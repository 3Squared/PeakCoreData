//
//  ConcurrentOperation.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit

// Slightly experimental version of our core data operation that uses child context.
// This means changes are saved up the chain rather than being merged in to the main context.

open class ConcurrentOperation: Operation {
    
    private var _executing = false
    private var _finished = false
    
    // MARK: - Operation Overrides
    
    public final override func start() {
        guard !isCancelled else {
            willChangeValue(forKey: #keyPath(Operation.isFinished))
            _finished = true
            didChangeValue(forKey: #keyPath(Operation.isFinished))
            return
        }
        
        willChangeValue(forKey: #keyPath(Operation.isExecuting))
        _executing = true
        didChangeValue(forKey: #keyPath(Operation.isExecuting))
        
        execute()
    }
    
    public final override var isExecuting: Bool {
        return _executing
    }
    
    public final override var isFinished: Bool {
        return _finished
    }
    
    public final override var isConcurrent: Bool {
        return true
    }
    
    open func execute() {
        print("\(self) must override `execute()`.")
        finish()
    }
    
    public func finish() {
        willChangeValue(forKey: #keyPath(Operation.isFinished))
        willChangeValue(forKey: #keyPath(Operation.isExecuting))
        
        _executing = false
        _finished = true
        
        didChangeValue(forKey: #keyPath(Operation.isFinished))
        didChangeValue(forKey: #keyPath(Operation.isExecuting))
    }
}
