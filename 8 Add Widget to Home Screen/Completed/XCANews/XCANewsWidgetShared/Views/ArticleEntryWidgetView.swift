//
//  ArticleEntryWidgetView.swift
//  XCANews
//
//  Created by Alfian Losari on 10/16/21.
//

import SwiftUI
import WidgetKit

struct ArticleEntryWidgetView: View {
    
    let entry: ArticleEntry
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        switch entry.state {
        
        case .articles(let articles):
            switch widgetFamily {
            case .systemSmall, .systemMedium:
                ArticleThumbnailView(article: articles[0], category: entry.category)
                    .widgetURL(articles[0].url)
                
                
            case .systemLarge:
                ArticleEntryWidgetLargeView(articles: articles, category: entry.category)
                
            case .systemExtraLarge:
                ArticleEntryWidgetExtraLargeView(articles: articles, category: entry.category)
                

            default: EmptyView()
            }
            
        
        case .failure(let error):
            
            Text(error.localizedDescription)
            
            
        }
    }
}

struct ArticleEntryWidgetLargeView: View {
    
    let articles: [ArticleWidgetModel]
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Link(destination: articles[0].url) {
                ArticleThumbnailView(article: articles[0], category: category)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
            
            ArticleGroupView(articles: Array(articles.dropFirst().prefix(3)))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
}

struct ArticleEntryWidgetExtraLargeView: View {
    
    let articles: [ArticleWidgetModel]
    let category: Category
    
    var body: some View {
        HStack {
            Link(destination: articles[0].url) {
                ArticleThumbnailView(article: articles[0], category: category)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
            
            ArticleGroupView(articles: Array(articles.dropFirst().prefix(5)))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
}





struct ArticleEntryWidgetView_Previews: PreviewProvider {
    
    static let stubs = ArticleEntry.stubArticles
    
    static var previews: some View {
        Group {
            ArticleEntryWidgetView(entry: stubs)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            ArticleEntryWidgetView(entry: stubs)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            ArticleEntryWidgetView(entry: stubs)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            
            #if os(iOS)
            ArticleEntryWidgetView(entry: stubs)
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            #endif
            
            ArticleEntryWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            ArticleEntryWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            ArticleEntryWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            
            #if os(iOS)
            ArticleEntryWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            #endif
            
        }
    }
}
