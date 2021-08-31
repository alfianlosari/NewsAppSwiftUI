//
//  ArticleDetailView.swift
//  ArticleDetailView
//
//  Created by Alfian Losari on 8/29/21.
//

import SwiftUI

struct ArticleDetailView: View {
    
    @EnvironmentObject private var bookmarkVM: ArticleBookmarkViewModel
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.title)
                .foregroundStyle(.primary)
                .padding(.bottom)
            
            Text(article.captionText)
                .font(.subheadline)
                .padding(.bottom)
            
            detailView
        }
    }
    
    private var detailView: some View {
        HStack(alignment: .top) {
            asyncImage
            Spacer()
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    Text(article.descriptionText)
                        .font(.headline)
                    
                    Text(article.url)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        bookmarkVM.toggleBookmark(for: article)
                    } label: {
                        if bookmarkVM.isBookmarked(for: article) {
                            Label("Remove from Bookmark", systemImage: "bookmark.fill")
                        } else {
                            Label("Add to Bookmark", systemImage: "bookmark")
                        }
                    }
                }
            }
        }
    }
    
    private var asyncImage: some View {
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
        .frame(minWidth: 400, minHeight: 400, maxHeight: 648)
        .background(Color.gray.opacity(0.6))
        .clipped()
        .cornerRadius(16)
    }
    
}

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArticleDetailView(article: Article.previewData[1])
                .environmentObject(ArticleBookmarkViewModel.shared)
        }
    }
}
