//
//  XCANewsMacApp.swift
//  XCANewsMac
//
//  Created by Alfian Losari on 7/24/21.
//

import SwiftUI

@main
struct XCANewsMacApp: App {
    
    @StateObject private var bookmarkVM: ArticleBookmarkViewModel = ArticleBookmarkViewModel.shared
    @StateObject private var searchVM: ArticleSearchViewModel = ArticleSearchViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookmarkVM)
                .environmentObject(searchVM)
        }
        .commands {
            SidebarCommands()
            NewsCommands()
        }
        
        Settings {
            SettingsView()
                .environmentObject(bookmarkVM)
                .environmentObject(searchVM)
        }
    }
}
