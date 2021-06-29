//
//  XCANewsApp.swift
//  XCANews
//
//  Created by Alfian Losari on 6/27/21.
//

import SwiftUI

@main
struct XCANewsApp: App {
    
    @StateObject var articleBookmarkVM = ArticleBookmarkViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(articleBookmarkVM)
        }
    }
}
