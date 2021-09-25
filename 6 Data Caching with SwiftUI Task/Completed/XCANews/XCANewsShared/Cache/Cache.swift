//
//  Cache.swift
//  Cache
//
//  Created by Alfian Losari on 9/13/21.
//

import Foundation

protocol Cache: Actor {
    
    associatedtype V
    var expirationInterval: TimeInterval { get }
    
    func setValue(_ value: V?, forKey key: String)
    func value(forKey key: String) -> V?
    
    func removeValue(forKey key: String)
    func removeAllValues()
}
