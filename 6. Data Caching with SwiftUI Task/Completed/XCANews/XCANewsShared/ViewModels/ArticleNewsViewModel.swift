//
//  ArticleNewsViewModel.swift
//  XCANews
//
//  Created by Alfian Losari on 6/27/21.
//

import SwiftUI

struct FetchTaskToken: Equatable {
    var category: Category
    var token: Date
}

fileprivate let dateFormatter = DateFormatter()

@MainActor
class ArticleNewsViewModel: ObservableObject {
    
    @Published var phase = DataFetchPhase<[Article]>.empty
    @Published var fetchTaskToken: FetchTaskToken {
        didSet {
            if oldValue.category != fetchTaskToken.category {
                selectedMenuItemId = MenuItem.category(fetchTaskToken.category).id
            }
        }
    }
    @AppStorage("item_selection") private var selectedMenuItemId: MenuItem.ID?
//    private let cache = InMemoryCache<[Article]>(expirationInterval: 2 * 60)
    private let cache = DiskCache<[Article]>(filename: "xca_news_articles", expirationInterval: 3 * 60)

    private let newsAPI = NewsAPI.shared
    
    var lastRefreshedDateText: String {
        dateFormatter.timeStyle = .short
        return "Last refreshed at: \(dateFormatter.string(from: fetchTaskToken.token))"
    }
    
    init(articles: [Article]? = nil, selectedCategory: Category = .general) {
        if let articles = articles {
            self.phase = .success(articles)
        } else {
            self.phase = .empty
        }
        self.fetchTaskToken = FetchTaskToken(category: selectedCategory, token: Date())
        
        Task(priority: .userInitiated) {
            try? await cache.loadFromDisk()
        }
    }
    
    func refreshTask() async {
        await cache.removeValue(forKey: fetchTaskToken.category.rawValue)
        fetchTaskToken.token = Date()
    }
    
    func loadArticles() async {
        if Task.isCancelled { return }
        
        let category = fetchTaskToken.category
        if let articles = await cache.value(forKey: category.rawValue) {
            phase = .success(articles)
            print("CACHE HIT")
            return
        }
        
        print("CACHE MISSED/EXPIRED")
        phase = .empty
        do {
            let articles = try await newsAPI.fetch(from: fetchTaskToken.category)
            if Task.isCancelled { return }
            await cache.setValue(articles, forKey: category.rawValue)
            try? await cache.saveToDisk()
            
            print("CACHE SET")
            phase = .success(articles)
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
}
