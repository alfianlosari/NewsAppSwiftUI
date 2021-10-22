//
//  ArticleSearchViewModel.swift
//  XCANews
//
//  Created by Alfian Losari on 6/27/21.
//

import Combine
import SwiftUI

@MainActor
class ArticleSearchViewModel: ObservableObject {

    @Published var phase: DataFetchPhase<[Article]> = .empty
    @Published var searchQuery = ""
    @Published var history = [String]()
    @Published var currentSearch: String?
    private let historyDataStore = PlistDataStore<[String]>(filename: "histories")
    private let historyMaxLimit = 10
    
    private var cancellables = Set<AnyCancellable>()
    
    private let newsAPI = NewsAPI.shared
    
    static let shared = ArticleSearchViewModel()
    private var trimmedSearchQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private init() {
        load()
        #if os(tvOS)
        observeSearchQuery()
        #endif
    }
    
    private func observeSearchQuery() {
        $searchQuery
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { query in
                Task { [weak self] in
                    guard let self = self else { return }
                    // we need to pass the query as publishing occur in willSet block so the Published property query has not reflecting the latest value.
                    await self.searchArticle(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    func addHistory(_ text: String) {
        if let index = history.firstIndex(where: { text.lowercased() == $0.lowercased() }) {
            history.remove(at: index)
        } else if history.count == historyMaxLimit {
            history.remove(at: history.count - 1)
        }
        
        history.insert(text, at: 0)
        historiesUpdated()
    }
    
    func removeHistory(_ text: String) {
        guard let index = history.firstIndex(where: { text.lowercased() == $0.lowercased() }) else {
            return
        }
        history.remove(at: index)
        historiesUpdated()
    }
    
    func removeAllHistory() {
        history.removeAll()
        historiesUpdated()
    }
    
    func searchArticle(query: String? = nil) async {
        if Task.isCancelled { return }
        
        let searchQuery = query != nil ? query!.trimmingCharacters(in: .whitespacesAndNewlines) :  trimmedSearchQuery
        phase = .empty
        
        if searchQuery.isEmpty {
            return
        }
        
        currentSearch = searchQuery
        do {
            let articles = try await newsAPI.search(for: searchQuery)
            if Task.isCancelled { return }
            if searchQuery != trimmedSearchQuery {
                return
            }
            phase = .success(articles)
        } catch {
            if Task.isCancelled { return }
            if searchQuery != trimmedSearchQuery {
                return
            }
            phase = .failure(error)
        }
    }
    
    private func load() {
        Task {
            self.history = await historyDataStore.load() ?? []
        }
    }
    
    private func historiesUpdated() {
        let history = self.history
        Task {
            await historyDataStore.save(history)
        }
    }
}
