//
//  ArticleProvider.swift
//  XCANews
//
//  Created by Alfian Losari on 10/16/21.
//

import Foundation
import WidgetKit

struct ArticleProvider: IntentTimelineProvider {
    
    typealias Entry = ArticleEntry
    typealias Intent = SelectCategoryIntent
    
    private let newsAPI = NewsAPI.shared
    private let urlSession = URLSession.shared
    
    func placeholder(in context: Context) -> ArticleEntry {
        .placeholder
    }
    
    func getSnapshot(for configuration: SelectCategoryIntent, in context: Context, completion: @escaping (ArticleEntry) -> Void) {
        Task {
            let entry = await getArticleEntry(for: Category(configuration.category))
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: SelectCategoryIntent, in context: Context, completion: @escaping (Timeline<ArticleEntry>) -> Void) {
        Task {
            let entry = await getArticleEntry(for: Category(configuration.category))
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 60)))
            completion(timeline)
        }
    }
    
    private func getArticleEntry(for category: Category) async -> ArticleEntry {
        let entry: ArticleEntry
        do {
            let articles = try await getArticles(for: category)
            entry = articles.isEmpty ? .placeholder : .init(date: Date(), state: .articles(articles), category: category)
        } catch {
            entry = .init(date: Date(), state: .failure(error), category: category)
        }
        return entry
    }
    
    private func getArticles(for category: Category) async throws -> [ArticleWidgetModel] {
        let articles = try await newsAPI.fetch(from: category,  pageSize: 5)
        
        return try await withThrowingTaskGroup(of: ArticleWidgetModel.self) { group in
            for article in articles {
                group.addTask { await fetchImageData(from: article) }
            }
            
            var results = [ArticleWidgetModel]()
            for try await result in group {
                results.append(result)
            }
            
            return results.sorted { $0.article?.publishedAt ?? Date() > $1.article?.publishedAt ?? Date()}
        }
    }
    
    private func fetchImageData(from article: Article) async -> ArticleWidgetModel {
        guard let url = article.imageURL,
              let (data, response) = try? await urlSession.data(from: url),
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                  return .init(state: .article(article: article, imageData: nil))
              }
        
        return .init(state: .article(article: article, imageData: data))
    }
}
