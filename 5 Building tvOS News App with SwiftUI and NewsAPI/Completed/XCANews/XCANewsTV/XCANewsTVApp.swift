//
//  XCANewsTVApp.swift
//  XCANewsTV
//
//  Created by Alfian Losari on 8/29/21.
//

import SwiftUI

@main
struct XCANewsTVApp: App {
    
    @StateObject private var bookmarkVM = ArticleBookmarkViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(bookmarkVM)
        }
    }
}
