//
//  Cache.swift
//  PeakCoreData-iOS
//
//  Created by David Yates on 02/04/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

// Adapted from: https://www.swiftbysundell.com/articles/caching-in-swift/

import Foundation

/// Provides a wrapped around `NSCache` that doesn't require keys to subclass `NSObject`.
public final class Cache<Key: Hashable, Value>: NSObject, NSCacheDelegate {
    
    private let wrapped = NSCache<WrappedKey, Entry>()
    
    public override init() {}
    
    /// The name of the cache. Default value is an empty string.
    public var name: String {
        set { wrapped.name = newValue }
        get { return wrapped.name }
    }
    
    /// The maximum number of objects the cache should hold. Default value is 0 (no limit).
    public var countLimit: Int {
        set { wrapped.countLimit = newValue }
        get { return wrapped.countLimit }
    }
    
    /// The maximum total cost that the cache can hold before it starts evicting objects. Default value is 0 (no limit).
    public var totalCostLimit: Int {
        set { wrapped.totalCostLimit = newValue }
        get { return wrapped.totalCostLimit }
    }
    
    /// Called when an object is about to be evicted or removed from the cache.
    public var onObjectEviction: ((Value) -> Void)? {
        didSet {
            wrapped.delegate = onObjectEviction != nil ? self : nil
        }
    }
        
    /// Sets the value of the specified key in the cache, and associates the key-value pair with the specified cost.
    public func insert(_ value: Value, forKey key: Key, cost: Int = 0) {
        let entry = Entry(value: value)
        let key = WrappedKey(key)
        wrapped.setObject(entry, forKey: key, cost: cost)
    }
    
    /// Returns the value associated with a given key.
    public func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }
    
    /// Removes the value of the specified key in the cache.
    public func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    /// Empties the cache.
    public func clearCache() {
        wrapped.removeAllObjects()
    }
    
    public func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        guard let entry = obj as? Entry else { return }
        onObjectEviction?(entry.value)
    }
}

extension Cache {
    
    public subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }
            insert(value, forKey: key)
        }
    }
}

extension Cache {
    
    private final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) {
            self.key = key
        }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }
    
    private final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}
