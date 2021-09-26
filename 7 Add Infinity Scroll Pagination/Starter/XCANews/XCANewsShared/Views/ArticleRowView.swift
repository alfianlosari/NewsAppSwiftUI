//
//  ArticleRowView.swift
//  XCANews
//
//  Created by Alfian Losari on 6/27/21.
//

import SwiftUI

struct ArticleRowView: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @EnvironmentObject var articleBookmarkVM: ArticleBookmarkViewModel
    
    let article: Article
    var body: some View {
        #if os(iOS)
        switch horizontalSizeClass {
        case .regular:
            GeometryReader { contentView(proxy: $0) }
        default:
            contentView()
        }
        #elseif os(macOS)
            GeometryReader { contentView(proxy: $0) }
        #elseif os(watchOS)
            watchContentView
        #endif
    }
    
    @ViewBuilder
    private func contentView(proxy: GeometryProxy? = nil) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            asyncImage
            
            VStack(alignment: .leading, spacing: 0) {
                Text(article.title)
                    .padding(.bottom, 8)
                #if os(iOS)
                    .font(.headline)
                #elseif os(macOS)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                #endif
                    .lineLimit(3)
                
                Text(article.descriptionText)
                #if os(iOS)
                    .font(.subheadline)
                    .lineLimit(2)
                #elseif os(macOS)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
                    .lineLimit(3)
                #endif
                
                
                #if os(iOS)
                if horizontalSizeClass == .regular {
                    Spacer()
                }
                #elseif os(macOS)
                Spacer()
                Divider()
                    .padding(.bottom, 12)
                #endif
                
                HStack {
                    Text(article.captionText)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Spacer()
                    
                    Button {
                        articleBookmarkVM.toggleBookmark(for: article)
                    } label: {
                        Image(systemName: articleBookmarkVM.isBookmarked(for: article) ? "bookmark.fill" : "bookmark")
                    }
                    
                    #if os(iOS)
                    shareButton(proxy: proxy)
                    #elseif os(macOS)
                    GeometryReader { shareButton(proxy: $0) }
                        .frame(width: 20, height: 20)
                    #endif
                }
                #if os(iOS)
                .buttonStyle(.bordered)
                #elseif os(macOS)
                .buttonStyle(.borderless)
                .imageScale(.large)
                #endif
                
            }
            .padding([.horizontal, .bottom])
        }
        #if os(macOS)
        .contextMenu(ContextMenu { contextMenu })
        #endif
    }
    
    private func shareButton(proxy: GeometryProxy?) -> some View {
        Button {
            presentShareSheet(url: article.articleURL, proxy: proxy)
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    #if os(macOS)
    @ViewBuilder
    private var contextMenu: some View {
        Button("Open in Browser") {
            NSWorkspace.shared.open(article.articleURL)
        }
         
        Button("Copy URL") {
            let url = article.articleURL as NSPasteboardWriting
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([url])
        }
        
        Button(articleBookmarkVM.isBookmarked(for: article) ? "Remove Bookmark" : "Bookmark") {
            articleBookmarkVM.toggleBookmark(for: article)
        }
    }
    #endif
    
    #if os(watchOS)
    private var watchContentView: some View {
        VStack(alignment: .leading) {
            HStack {
                asyncImage
                Text(article.title)
                    .lineLimit(3)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            Text(article.descriptionText)
                .lineLimit(2)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            
            HStack {
                if articleBookmarkVM.isBookmarked(for: article) {
                    Image(systemName: "bookmark")
                }
                
                Text(article.captionText)
                    .font(.footnote)
                    .lineLimit(2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical)
        .swipeActions {
            if articleBookmarkVM.isBookmarked(for: article) {
                Button(role: .destructive, action: {
                    articleBookmarkVM.removeBookmark(for: article)
                }, label: {
                    Label("Remove Bookmark", systemImage: "bookmark")
                })
            } else {
                Button(action: {
                    articleBookmarkVM.addBookmark(for: article)
                }, label: {
                    Label("Bookmark", systemImage: "bookmark")
                })
            }
        }
    }
    #endif
    
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
        #if os(iOS)
        .asyncImageFrame(horizontalSizeClass: horizontalSizeClass ?? .compact)
        #elseif os(macOS)
        .frame(height: 180)
        #elseif os(watchOS)
        .frame(maxWidth: 40, maxHeight: 70)
        #endif
        .background(Color.gray.opacity(0.6))
        #if os(watchOS)
        .cornerRadius(4)
        #endif
        .clipped()
    }
}

extension View {
    
    func presentShareSheet(url: URL, proxy: GeometryProxy? = nil) {
        #if os(iOS)
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        guard let rootVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .keyWindow?
            .rootViewController else { return }
        
        activityVC.popoverPresentationController?.sourceView = rootVC.view
        if let proxy = proxy {
            activityVC.popoverPresentationController?.sourceRect = proxy.frame(in: .global)
        }
        rootVC.present(activityVC, animated: true)
        #elseif os(macOS)
        guard let contentView = NSApp.keyWindow?.contentView,
              let proxy = proxy
        else {
            return
        }
        
        let frame = proxy.frame(in: .global)
        let shareServicePicker = NSSharingServicePicker(items: [url])
        shareServicePicker.show(relativeTo: frame, of: contentView, preferredEdge: .minY)
        #endif
    }
    
}

#if os(iOS)
fileprivate extension View {
    
    @ViewBuilder
    func asyncImageFrame(horizontalSizeClass: UserInterfaceSizeClass) -> some View {
        switch horizontalSizeClass {
        case .regular:
            frame(height: 180)
        default:
            frame(minHeight: 200, maxHeight: 300)
        }
    }
    
}
#endif

struct ArticleRowView_Previews: PreviewProvider {
    
    @StateObject static var articleBookmarkVM = ArticleBookmarkViewModel.shared

    static var previews: some View {
        NavigationView {
            List {
                ArticleRowView(article: .previewData[0])
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .listStyle(.plain)
        }
        .environmentObject(articleBookmarkVM)
    }
}
