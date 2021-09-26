//
//  CacheImplementation.swift
//  CacheImplementation
//
//  Created by Alfian Losari on 9/12/21.
//

import Foundation

fileprivate protocol NSCacheType: Cache {
    var cache: NSCache<NSString, CacheEntry<V>> { get }
    var keysTracker: KeysTracker<V> { get }
}

actor InMemoryCache<V>: NSCacheType {
    
    fileprivate let cache: NSCache<NSString, CacheEntry<V>> = .init()
    fileprivate let keysTracker: KeysTracker<V> = .init()
    
    let expirationInterval: TimeInterval
    
    init(expirationInterval: TimeInterval) {
        self.expirationInterval = expirationInterval
    }
}

actor DiskCache<V: Codable>: NSCacheType {
    
    fileprivate let cache: NSCache<NSString, CacheEntry<V>> = .init()
    fileprivate let keysTracker: KeysTracker<V> = .init()
    
    let filename: String
    let expirationInterval: TimeInterval
    
    init(filename: String, expirationInterval: TimeInterval) {
        self.filename = filename
        self.expirationInterval = expirationInterval
    }
    
    private var saveLocationURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(filename).cache")
    }
    
    func saveToDisk() throws {
        let entries = keysTracker.keys.compactMap(entry)
        let data = try JSONEncoder().encode(entries)
        try data.write(to: saveLocationURL)
    }
    
    func loadFromDisk() throws {
        let data = try Data(contentsOf: saveLocationURL)
        let entries = try JSONDecoder().decode([CacheEntry<V>].self, from: data)
        entries.forEach { insert($0) }
    }
    
}


extension NSCacheType {
    
    func removeValue(forKey key: String) {
        keysTracker.keys.remove(key)
        cache.removeObject(forKey: key as NSString)
    }
    
    func removeAllValues() {
        keysTracker.keys.removeAll()
        cache.removeAllObjects()
    }
    
    func setValue(_ value: V?, forKey key: String) {
        if let value = value {
            let expiredTimestamp = Date().addingTimeInterval(expirationInterval)
            let cacheEntry = CacheEntry(key: key, value: value, expiredTimestamp: expiredTimestamp)
            insert(cacheEntry)
        } else {
            removeValue(forKey: key)
        }
    }
    
    func value(forKey key: String) -> V? {
        entry(forKey: key)?.value
    }
    
    func entry(forKey key: String) -> CacheEntry<V>? {
        guard let entry = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        guard !entry.isCacheExpired(after: Date()) else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry
    }
    
    func insert(_ entry: CacheEntry<V>) {
        keysTracker.keys.insert(entry.key)
        cache.setObject(entry, forKey: entry.key as NSString)
    }
    
}
