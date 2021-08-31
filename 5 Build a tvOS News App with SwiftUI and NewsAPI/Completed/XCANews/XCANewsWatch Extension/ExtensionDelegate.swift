//
//  ExtensionDelegate.swift
//  ExtensionDelegate
//
//  Created by Alfian Losari on 8/15/21.
//

import WatchKit
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    private let newsAPI = NewsAPI.shared
    private var dataStore = ArticleDataStore()
    
    private var selectedComplicationCategory: Category {
        guard let value = UserDefaults.standard.value(forKey: complicationCategoryKey) as? String,
              let category = Category(rawValue: value) else {
                  return .general
              }
        
        return category
    }
    
    func applicationDidFinishLaunching() {
        scheduleNextReload()
        if dataStore.lastArticle == nil {
            refreshComplicationCategory(category: selectedComplicationCategory)
        } else {
            reloadActiveComplications()
        }
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let task as WKApplicationRefreshBackgroundTask:
                refreshComplicationCategory(category: selectedComplicationCategory) {
                    task.setTaskCompletedWithSnapshot($0)
                }
                scheduleNextReload()
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    func handleUserActivity(_ userInfo: [AnyHashable : Any]?) {
        if userInfo?[CLKLaunchedComplicationIdentifierKey] != nil,
           let article = dataStore.lastArticle {
            NotificationCenter.default.post(name: .articleSent,
                                            object: nil,
                                            userInfo: ["article": article]
            )
            
        }
    }
    
    private func refreshComplicationCategory(category: Category = .general, completion: @escaping ((Bool) -> ()) = { _ in }) {
        Task(priority: .high) {
            guard let articles = try? await newsAPI.fetch(from: category),
                  let article = articles.randomElement() else {
                      completion(false)
                      return
                  }
            dataStore.lastArticle = article
            reloadActiveComplications()
            completion(true)
        }
    }
    
    private func reloadActiveComplications() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
    }
    
    private func scheduleNextReload() {
        let targetDate = Date().addingTimeInterval(60 * 60)
        WKExtension.shared().scheduleBackgroundRefresh(
            withPreferredDate: targetDate,
            userInfo: nil) { _ in }
    }
}
