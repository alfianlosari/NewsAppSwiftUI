//
//  ArticleDetailView.swift
//  ArticleDetailView
//
//  Created by Alfian Losari on 8/14/21.
//

import SwiftUI

struct ArticleDetailView: View {
    
    let article: Article
    @EnvironmentObject private var bookmarkVM: ArticleBookmarkViewModel
    @EnvironmentObject private var connectivityVM: WatchConnectivityViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
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
                .cornerRadius(4)
                .clipped()
                
                HStack {
                    Button {
                        bookmarkVM.toggleBookmark(for: article)
                    } label: {
                        Image(systemName: bookmarkVM.isBookmarked(for: article) ? "bookmark.fill" : "bookmark")
                            .imageScale(.large)
                    }
                    
                    if connectivityVM.isReachable {
                        if connectivityVM.isSending {
                            ProgressView()
                                .frame(height: 20)
                        } else {
                            Button {
                                connectivityVM.sendURLToiPhone(article: article)
                            } label: {
                                Image(systemName: "arrow.turn.up.forward.iphone")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
                
                Text(article.descriptionText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                Text(article.captionText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .userActivity(activityTypeViewKey, element: article) { article, userActivity in
            userActivity.isEligibleForHandoff = true
            userActivity.requiredUserInfoKeys = [activityURLKey]
            userActivity.addUserInfoEntries(from: [activityURLKey: article.articleURL.absoluteString])
        }
    }
}

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleDetailView(article: Article.previewData[2])
            .environmentObject(ArticleBookmarkViewModel.shared)
            .environmentObject(WatchConnectivityViewModel.shared)
    }
}
