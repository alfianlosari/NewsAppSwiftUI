//
//  TabMenuItem.swift
//  XCANews
//
//  Created by Alfian Losari on 7/11/21.
//

import Foundation

enum TabMenuItem: String, CaseIterable {
    case news
    case search
    case saved
    
    var text: String { rawValue.capitalized }
    var systemImage: String {
        switch self {
        case .news:
            return "newspaper"
        case .search:
            return "magnifyingglass"
        case .saved:
            return "bookmark"
        }
    }
    
    init(menuItem: MenuItem.ID?) {
        switch MenuItem(id: menuItem) {
        case .search:
            self = .search
        case .saved:
            self = .saved
        default:
            self = .news
        }
    }
    
    func menuItemId(category: Category?) -> MenuItem.ID {
        switch self {
        case .news:
            return MenuItem.category(category ?? .general).id
        case .search:
            return MenuItem.search.id
        case .saved:
            return MenuItem.saved.id
        }
    }
    
}

extension TabMenuItem: Identifiable {
    
    var id: Self { self }
}
