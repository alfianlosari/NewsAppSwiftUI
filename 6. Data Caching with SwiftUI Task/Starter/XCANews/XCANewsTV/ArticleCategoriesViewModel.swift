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
    
    var categoryArticles: [CategoryArticles] {
        phase.value ?? []
    }
    
    func loadCategoryArticles() async {
        if Task.isCancelled { return }
        phase = .empty

        do {
            let categoryArticles = try await newsAPI.fetchAllCategoryArticles()
            if Task.isCancelled { return }
            phase = .success(categoryArticles)
        } catch {
            if Task.isCancelled { return }
            phase = .failure(error)
        }
    }
    
}
