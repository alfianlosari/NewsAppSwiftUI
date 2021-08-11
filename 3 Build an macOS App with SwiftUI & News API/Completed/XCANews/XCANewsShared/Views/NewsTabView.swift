//
//  NewsTabView.swift
//  XCANews
//
//  Created by Alfian Losari on 6/27/21.
//

import SwiftUI

struct NewsTabView: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @StateObject var articleNewsVM: ArticleNewsViewModel
    
    init(articles: [Article]? = nil, category: Category = .general) {
        self._articleNewsVM = StateObject(wrappedValue: ArticleNewsViewModel(articles: articles, selectedCategory: category))
    }
    
    var body: some View {
        ArticleListView(articles: articles)
            .overlay(overlayView)
            .task(id: articleNewsVM.fetchTaskToken, loadTask)
            .refreshable(action: refreshTask)
            .navigationTitle(articleNewsVM.fetchTaskToken.category.text)
            #if os(iOS)
            .navigationBarItems(trailing: navigationBarItem)
            #elseif os(macOS)
            .navigationSubtitle(articleNewsVM.lastRefreshedDateText)
            .focusedSceneValue(\.refreshAction, refreshTask)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: refreshTask) {
                        Image(systemName: "arrow.clockwise")
                            .imageScale(.large)
                    }
                }
            }
            #endif
    }
    
    @ViewBuilder
    private var overlayView: some View {
        
        switch articleNewsVM.phase {
        case .empty:
            ProgressView()
        case .success(let articles) where articles.isEmpty:
            EmptyPlaceholderView(text: "No Articles", image: nil)
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: refreshTask)
        default: EmptyView()
        }
    }
    
    private var articles: [Article] {
        if case let .success(articles) = articleNewsVM.phase {
            return articles
        } else {
            return []
        }
    }
    
    @Sendable
    private func loadTask() async {
        await articleNewsVM.loadArticles()
    }
    
    @Sendable
    private func refreshTask() {
        DispatchQueue.main.async {
            articleNewsVM.fetchTaskToken = FetchTaskToken(category: articleNewsVM.fetchTaskToken.category, token: Date())
        }
    }
    
    #if os(iOS)
    @ViewBuilder
    private var navigationBarItem: some View {
        switch horizontalSizeClass {
        case .regular:
            Button(action: refreshTask) {
                Image(systemName: "arrow.clockwise")
                    .imageScale(.large)
            }
            
        default:
            Menu {
                Picker("Category", selection: $articleNewsVM.fetchTaskToken.category) {
                    ForEach(Category.allCases) {
                        Text($0.text).tag($0)
                    }
                }
            } label: {
                Image(systemName: "fiberchannel")
                    .imageScale(.large)
            }
        }
    }
    #endif

}

struct NewsTabView_Previews: PreviewProvider {
    
    @StateObject static var articleBookmarkVM = ArticleBookmarkViewModel.shared

    
    static var previews: some View {
        NewsTabView(articles: Article.previewData)
            .environmentObject(articleBookmarkVM)
    }
}
