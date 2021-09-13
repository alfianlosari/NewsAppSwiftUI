//
//  XCANewsApp.swift
//  XCANewsWatch Extension
//
//  Created by Alfian Losari on 8/14/21.
//

import SwiftUI
import WatchKit

@main
struct XCANewsApp: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) private var extensionDelegate
    @StateObject private var bookmarkVM = ArticleBookmarkViewModel.shared
    @StateObject private var searchVM = ArticleSearchViewModel.shared
    @StateObject private var connectivityVM = WatchConnectivityViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(bookmarkVM)
            .environmentObject(searchVM)
            .environmentObject(connectivityVM)
        }
    }
}
