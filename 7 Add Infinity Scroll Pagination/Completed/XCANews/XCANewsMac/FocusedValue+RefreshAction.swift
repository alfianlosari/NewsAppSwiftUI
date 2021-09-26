//
//  FocusedValue+RefreshAction.swift
//  FocusedValue+RefreshAction
//
//  Created by Alfian Losari on 7/25/21.
//

import SwiftUI

fileprivate var _refreshAction: (() -> Void)?

extension FocusedValues {
    
    var refreshAction: (() -> Void)? {
        get {
//            self[RefreshActionKey.self]
            _refreshAction
        }
        
        set {
//            self[RefreshActionKey.self] = newValue
            _refreshAction = newValue
        }
        
    }
    
    struct RefreshActionKey: FocusedValueKey {
        typealias Value = () -> Void
    }
    
}
