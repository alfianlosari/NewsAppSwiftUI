//
//  ArticleItemView.swift
//  ArticleItemView
//
//  Created by Alfian Losari on 8/29/21.
//

import SwiftUI

struct ArticleItemView: View {
    
    let article: Article
    @EnvironmentObject private var bookmarkVM: ArticleBookmarkViewModel
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 24) {
                asyncImage
                    .frame(height: proxy.size.height * 0.6)
                    .background(Color.gray.opacity(0.6))
                    .clipped()
                
                VStack(alignment: .leading) {
                    Text(article.title)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                    
                    Spacer(minLength: 12)
                    
                    HStack {
                        Text(article.source.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        
                        if bookmarkVM.isBookmarked(for: article) {
                            Spacer()
                            Image(systemName: "bookmark.fill")
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
    }
    
    private var asyncImage: some View  {
        AsyncImage(url: article.imageURL) { phase in
            switch phase {
            case .empty:
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
            case .failure:
                HStack {
                    Spacer()
                    Image(systemName: "photo")
                        .imageScale(.large)
                    Spacer()
                }
                
                
            @unknown default:
                fatalError()
            }
        }
    }
}

struct ArticleItemView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleItemView(article: Article.previewData[2])
            .frame(width: 400, height: 400)
            .environmentObject(ArticleBookmarkViewModel.shared)
        
    }
}
