//
//  ArticleCategoriesViewModel.swift
//  ArticleCategoriesViewModel
//
//  Created by Alfian Losari on 8/29/21.
//

import SwiftUI

struct Cache<T> {
    
    private var value: T?
    private var timestamp: Date?
    private(set) var expirationInterval: TimeInterval
    
    init(expirationInterval: TimeInterval) {
        self.expirationInterval = expirationInterval
    }
    
    mutating func getValue() -> T? {
        if let value = value, let timestamp = timestamp,
           (Date().timeIntervalSinceNow - timestamp.timeIntervalSinceNow) < expirationInterval {
            return value
        } else {
            clearCache()
            return nil
        }
    }
    
    mutating func updateCache(value: T) {
        self.value = value
        self.timestamp = Date()
    }
    
    mutating func clearCache() {
        self.value = nil
        self.timestamp = nil
    }
    
}


@MainActor
class ArticleCategoriesViewModel: ObservableObject {
    
    @Published var phase = DataFetchPhase<[CategoryArticles]>.empty
    var cache = Cache<[CategoryArticles]>(expirationInterval: 60 * 5)
    
    private let newsAPI = NewsAPI.shared
    
    var categoryArticles: [CategoryArticles] {
        phase.value ?? []
    }
    
    func loadCategoryArticles() async {
//        phase = .success([])
        if let articles = cache.getValue() {
            phase = .success(articles)
            return
        }
        
        if Task.isCancelled { return }
        phase = .empty

        do {
            let categoryArticles = try await newsAPI.fetchAllCategoryArticles()
            if Task.isCancelled { return }
            cache.updateCache(value: categoryArticles)
            phase = .success(categoryArticles)
        } catch {
            if Task.isCancelled { return }
            phase = .failure(error)
        }
    }
    
}
