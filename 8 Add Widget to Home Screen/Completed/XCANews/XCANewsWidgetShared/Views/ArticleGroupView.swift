//
//  ArticleGroupView.swift
//  XCANews
//
//  Created by Alfian Losari on 10/16/21.
//

import SwiftUI
import WidgetKit

struct ArticleRowView: View {
    
    let article: ArticleWidgetModel
    
    var body: some View {
        HStack {
            if let imageData = article.imageData {
                ImageBackgroundView(data: imageData)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .lineLimit(1).font(.caption)
                
                Text(article.subtitle)
                    .lineLimit(2).font(.subheadline.weight(.semibold))
            }
        }
        .redacted(reason: article.isPlaceholder ? .placeholder : .init())
    }
    
}

struct ArticleGroupView: View {
    
    let articles: [ArticleWidgetModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(articles) { article in
                Link(destination: article.url) {
                    ArticleRowView(article: article)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if articles.last?.id != article.id {
                    Divider().frame(height: 0.5)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ArticleGroupView_Previews: PreviewProvider {
    
    static let stubs = ArticleWidgetModel.stubs
    
    static var previews: some View {
        Group {
            ArticleGroupView(articles: Array(stubs.prefix(upTo: 2)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            ArticleGroupView(articles: Array(stubs.prefix(upTo: 4)))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            ArticleGroupView(articles: Array(ArticleWidgetModel.placeholders.prefix(upTo: 2)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
