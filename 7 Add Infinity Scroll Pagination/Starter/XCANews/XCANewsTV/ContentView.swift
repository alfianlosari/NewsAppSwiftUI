//
//  ContentView.swift
//  XCANewsTV
//
//  Created by Alfian Losari on 8/29/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NewsView()
                .edgesIgnoringSafeArea(.horizontal)
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }
                .tag("news")
            
            BookmarkTabView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
                .tag("saved")
            
            SearchTabView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                .tag("search")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
