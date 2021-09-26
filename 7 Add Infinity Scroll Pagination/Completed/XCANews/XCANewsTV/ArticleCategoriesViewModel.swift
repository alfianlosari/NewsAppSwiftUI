//
//  ArticleCategoriesViewModel.swift
//  ArticleCategoriesViewModel
//
//  Created by Alfian Losari on 8/29/21.
//

import SwiftUI

@MainActor
class ArticleCategoriesViewModel: ObservableObject {
    
    @Published var phase = DataFetchPhase<[CategoryArticles]>.empty
    
    private let newsAPI = NewsAPI.shared
    
    private let cache: DiskCache<[CategoryArticles]> =
        .init(
            filename: "xcanewscache",
            expirationInterval: 5 * 60
        )
    
    var categoryArticles: [CategoryArticles] {
        phase.value ?? []
    }
    
    func loadCategoryArticles() async {
        if Task.isCancelled { return }
        if let articles = await cache.value(forKey: "news_list") {
            phase = .success(articles)
            return
        }
        
        phase = .empty

        do {
            let categoryArticles = try await newsAPI.fetchAllCategoryArticles()
            if Task.isCancelled { return }
            await cache.setValue(categoryArticles, forKey: "news_list")
            try? await cache.saveToDisk()
            
            phase = .success(categoryArticles)
        } catch {
            if Task.isCancelled { return }
            phase = .failure(error)
        }
    }
    
}

