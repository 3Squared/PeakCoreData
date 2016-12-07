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

internal extension Operation {
    
    enum KeyPath: String {
        case cancelled = "isCancelled"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    func willChangeValue(forKey key: KeyPath) {
        willChangeValue(forKey: key.rawValue)
    }
    
    func didChangeValue(forKey key: KeyPath) {
        didChangeValue(forKey: key.rawValue)
    }
}

open class ConcurrentOperation: Operation {
    
    private var _executing = false
    private var _finished = false
    
    // MARK: - Operation Overrides
    
    public final override func start() {
        guard !isCancelled else {
            willChangeValue(forKey: .finished)
            _finished = true
            didChangeValue(forKey: .finished)
            return
        }
        
        willChangeValue(forKey: .executing)
        _executing = true
        didChangeValue(forKey: .executing)
        
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
        willChangeValue(forKey: .finished)
        willChangeValue(forKey: .executing)

        _executing = false
        _finished = true
        
        didChangeValue(forKey: .finished)
        didChangeValue(forKey: .executing)
    }
}
