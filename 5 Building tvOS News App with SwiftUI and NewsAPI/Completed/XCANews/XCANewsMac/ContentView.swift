//
//  ContentView.swift
//  XCANewsMac
//
//  Created by Alfian Losari on 7/24/21.
//

import SwiftUI

struct ContentView: View {
    
    @SceneStorage("item_selection") private var selectedMenuItemId: MenuItem.ID?
    @EnvironmentObject private var searchVM: ArticleSearchViewModel
    @State private var isSearching = false
    
    private var selection: Binding<MenuItem.ID?> {
        Binding {
            if isSearching {
                return MenuItem.search.id
            }
            return selectedMenuItemId ?? MenuItem.category(.general).id
        } set: { newValue in
            if let newValue = newValue {
                if newValue == MenuItem.search.id {
                    isSearching = true
                    return
                }
                isSearching = false
                selectedMenuItemId = newValue
            }
        }
    }
    
    var body: some View {
        NavigationView {
            SidebarListView(selection: selection)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: toggleSidebar) {
                            Image(systemName: "sidebar.left")
                        }
                    }
                }
        }
        .frame(minWidth: 1000, minHeight: 386)
        .searchable(text: $searchVM.searchQuery, placement: .sidebar, prompt: "Search news") { suggestionView }
        .onSubmit(of: .search) { search() }
        .focusable()
        .touchBar {
            ScrollView(.horizontal) {
                HStack {
                    ForEach([MenuItem.saved] + Category.menuItems) { item in
                        Button {
                            selection.wrappedValue = item.id
                        } label: {
                            Label(item.text, systemImage: item.systemImage)
                        }
                    }
                }
            }
            .frame(width: 684)
            .touchBarItemPresence(.required("menus"))
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?
            .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    private func search() {
        let searchQuery = searchVM.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !searchQuery.isEmpty {
            searchVM.addHistory(searchQuery)
        } else {
            return
        }
        selection.wrappedValue = MenuItem.search.id
        
        Task {
            await searchVM.searchArticle()
        }
    }
    
    @ViewBuilder
    private var suggestionView: some View {
        Section {
            ForEach(["Swift", "BTC", "Covid-19", "PS5", "iOS15"], id: \.self) { text in
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.001))
                    .searchCompletion(text)
            }
        } header: {
            Text("Trending")
        }
        
        if !searchVM.history.isEmpty {
            Section {
                ForEach(searchVM.history, id: \.self) { text in
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.001))
                        .searchCompletion(text)
                }
            } header: {
                Text("Recent Searches")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
