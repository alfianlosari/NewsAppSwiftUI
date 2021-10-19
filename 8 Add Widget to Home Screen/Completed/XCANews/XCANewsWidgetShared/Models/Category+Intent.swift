//
//  Category+Intent.swift
//  XCANews
//
//  Created by Alfian Losari on 10/16/21.
//

import Foundation

extension Category {
    
    init(_ categoryIntentParam: CategoryIntentParam) {
        switch categoryIntentParam {
        case .general: self = .general
        case .business: self = .business
        case .entertainment: self = .entertainment
        case .technology: self = .technology
        case .sports: self = .sports
        case .science: self = .science
        case .health: self = .health
        case .unknown: self = .general
        }
    }
    
}
