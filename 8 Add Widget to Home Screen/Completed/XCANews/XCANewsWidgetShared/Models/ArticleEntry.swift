//
//  ArticleEntry.swift
//  XCANews
//
//  Created by Alfian Losari on 10/16/21.
//

import Foundation
import WidgetKit

struct ArticleEntry: TimelineEntry {
    
    enum State {
        case articles([ArticleWidgetModel])
        case failure(Error)
    }
    
    let date: Date
    let state: State
    let category: Category
    
}
