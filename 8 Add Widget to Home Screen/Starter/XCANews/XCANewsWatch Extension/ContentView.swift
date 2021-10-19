//
//  ContentView.swift
//  XCANewsWatch Extension
//
//  Created by Alfian Losari on 8/14/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedMenuItemId: MenuItem.ID?
    @EnvironmentObject private var searchVM: ArticleSearchViewModel
    @State private var complicationArticle: Article?
    
    var body: some View {
        ZStack {
            navigationLinkForMenuItem(MenuItem.search) {
                EmptyView()
            }
            .hidden()
            
            List {
                Section {
                    navigationLinkForMenuItem(.saved) {
                        Label(MenuItem.saved.text, systemImage: MenuItem.saved.systemImage)
                    }
                }
                
                Section {
                    ForEach(Category.menuItems) { item in
                        navigationLinkForMenuItem(item) {
                            listRowForCategoryMenuItem(item)
                        }
                    }
                } header: {
                    Text("Categories")
                }
                
                Section {
                    navigationLinkForMenuItem(.settings) {
                        Label(MenuItem.settings.text, systemImage: MenuItem.settings.systemImage)
                    }
                }
                
            }
            .sheet(item: $complicationArticle) {
                ArticleDetailView(article: $0)
            }
            .searchable(text: $searchVM.searchQuery)
            .onSubmit(of: .search, search)
            .navigationTitle("XCA News")
            .onReceive(NotificationCenter.default.publisher(for: .articleSent, object: nil)) { notification in
                guard let article = notification.userInfo?["article"] as? Article else {
                    return
                }
                complicationArticle = article
            }
        }
        
    }
    
    @ViewBuilder
    private func viewForMenuItem(_ item: MenuItem) -> some View {
        switch item {
        case .saved:
            BookmarkTabView()
            
        case .search:
            SearchTabView()
                .onDisappear {
                    searchVM.searchQuery = ""
                }
            
        case .category(let category):
            NewsTabView(category: category)
            
        case .settings:
            SettingsView()
        }
    }
    
    private func navigationLinkForMenuItem<Label: View>(_ item: MenuItem, @ViewBuilder label: () -> Label) -> some View {
        NavigationLink(
            destination: viewForMenuItem(item),
            tag: item.id,
            selection: $selectedMenuItemId) {
                label()
        }
        .listItemTint(item.listItemTintColor)
    }
    
    private func listRowForCategoryMenuItem(_ item: MenuItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: item.systemImage)
                .imageScale(.large)
            Text(item.text)
        }
        .padding(.vertical, 10)
    }
    
    private func search() {
        let searchQuery = searchVM.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchQuery.isEmpty {
            return
        }
        selectedMenuItemId = MenuItem.search.id
        Task {
            await searchVM.searchArticle()
        }
    }
}

fileprivate extension MenuItem {
    
    var listItemTintColor: Color? {
        switch self {
            
        case .category(let category):
            switch category {
            case .general:
                return .orange
            case .business:
                return .cyan
            case .technology:
                return .blue
            case .entertainment:
                return .indigo
            case .sports:
                return .purple
            case .science:
                return .brown
            case .health:
                return .red
            }
        default: return nil
        }
        
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ArticleBookmarkViewModel.shared)
            .environmentObject(ArticleSearchViewModel.shared)
    }
}
