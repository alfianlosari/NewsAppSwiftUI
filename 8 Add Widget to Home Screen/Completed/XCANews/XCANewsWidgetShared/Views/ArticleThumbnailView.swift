//
//  ArticleThumbnailView.swift
//  XCANews
//
//  Created by Alfian Losari on 10/16/21.
//

import SwiftUI
import WidgetKit

struct ArticleThumbnailView: View {
    
    let article: ArticleWidgetModel
    let category: Category
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ImageBackgroundView(data: article.imageData)
            Color.black.opacity(0.35)
            
            VStack(alignment: .leading) {
                
                Text(category.text)
                    .lineLimit(1)
                    .font(.subheadline)
                    
                Spacer()
                
                Text(article.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .font(.headline)

            }
            .foregroundColor(.white)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .redacted(reason: article.isPlaceholder ? .placeholder : .init())
    }
}

struct ArticleThumbnailView_Previews: PreviewProvider {
    
    static let stub = ArticleWidgetModel.stubArticleWithImageData
    
    static var previews: some View {
        Group {
            ArticleThumbnailView(
                article: stub,
                category: .general
            ).previewContext(WidgetPreviewContext(family: .systemSmall))
            
            ArticleThumbnailView(
                article: stub,
                category: .general
            ).previewContext(WidgetPreviewContext(family: .systemMedium))
            
            ArticleThumbnailView(
                article: stub,
                category: .general
            ).previewContext(WidgetPreviewContext(family: .systemLarge))
            
            ArticleThumbnailView(
                article: .init(state: .placeholder),
                category: .general
            ).previewContext(WidgetPreviewContext(family: .systemMedium))
            
        }
    }
}
