//
//  XCANewsMacApp.swift
//  XCANewsMac
//
//  Created by Alfian Losari on 7/24/21.
//

import SwiftUI
import Foundation
import WidgetKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        if let urlString = userActivity.userInfo?[activityURLKey] as? String,
           let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
        return true
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            NSWorkspace.shared.open(url)
        }
    }
    
}

@main
struct XCANewsMacApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var bookmarkVM: ArticleBookmarkViewModel = ArticleBookmarkViewModel.shared
    @StateObject private var searchVM: ArticleSearchViewModel = ArticleSearchViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookmarkVM)
                .environmentObject(searchVM)
        }
        .handlesExternalEvents(matching: [])
        
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {}
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
