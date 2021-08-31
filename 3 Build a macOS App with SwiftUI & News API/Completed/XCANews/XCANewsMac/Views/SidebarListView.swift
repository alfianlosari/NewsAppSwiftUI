//
//  SidebarListView.swift
//  SidebarListView
//
//  Created by Alfian Losari on 7/24/21.
//

import SwiftUI

struct SidebarListView: View {
    
    @Binding var selection: MenuItem.ID?
    @EnvironmentObject private var searchVM: ArticleSearchViewModel
    @Environment(\.dismissSearch) private var dismissSearch
    
    var body: some View {
        ZStack {
            navigationLink
                .opacity(0)
            
            List(selection: $selection) {
                
                Section {
                    listRow(MenuItem.saved)
                        .tag(MenuItem.saved.id)
                } header: {
                    Text("XCA News")
                }
                .collapsible(false)

                Section {
                    ForEach(Category.menuItems) {
                        listRow($0)
                            .tag($0.id)
                    }
                } header: {
                    Text("Categories")
                }
                .collapsible(false)
            }
            .listStyle(.sidebar)
            .frame(minWidth: 220)
            .padding(.top)
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
                    dismissSearch()
                }
            
        case .category(let category):
            NewsTabView(category: category)
                .id(category.id)
        }
    }
    
    @ViewBuilder
    private var navigationLink: some View {
        if let selectedMenuItem = MenuItem(id: selection) {
            NavigationLink(
                destination: viewForMenuItem(selectedMenuItem),
                tag: selectedMenuItem.id,
                selection: $selection) {
                    EmptyView()
                }
        }
    }
    
    private func listRow(_ item: MenuItem) -> some View {
        Label {
            Text(item.text)
                .padding(.leading, 4)
        } icon: {
            Image(systemName: item.systemImage)
        }
        .font(.title2)
        .padding(.vertical, 4)
    }
    
}

struct SidebarListView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarListView(selection: .constant(nil))
    }
}
