//
//  SettingsView.swift
//  SettingsView
//
//  Created by Alfian Losari on 7/25/21.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
        }
        .frame(width: 400, height: 100, alignment: .center)
    }
    
    private struct GeneralSettings: View {
        
        @EnvironmentObject var searchVM: ArticleSearchViewModel
        @EnvironmentObject var bookmarkVM: ArticleBookmarkViewModel
        
        var body: some View {
            Form {
                VStack {
                    HStack {
                        Text("Search history data:")
                            .frame(width: 150, alignment: .trailing)
                        
                        Button("Clear All") {
                            searchVM.removeAllHistory()
                        }
                        .frame(alignment: .trailing)
                    }
                    
                    HStack {
                        Text("Saved bookmarks data")
                            .frame(width: 150, alignment: .trailing)
                        
                        Button("Clear All") {
                            bookmarkVM.removeAllBookmarks()
                        }
                        .frame(alignment: .trailing)
                    }
                }
            }
            .fixedSize()
            .padding()
        }
        
        
    }
}
