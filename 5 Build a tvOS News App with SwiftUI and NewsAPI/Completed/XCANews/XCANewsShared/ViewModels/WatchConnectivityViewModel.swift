//
//  WatchConnectivityViewModel.swift
//  WatchConnectivityViewModel
//
//  Created by Alfian Losari on 8/14/21.
//

import SwiftUI
import WatchConnectivity

class WatchConnectivityViewModel: NSObject, ObservableObject, WCSessionDelegate {
    
    private let session = WCSession.default
    @Published var isReachable = false
    @Published var isSending = false
    
    static let shared = WatchConnectivityViewModel()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete \(activationState.rawValue)")
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    #if os(iOS)
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session did become inactive: \(session.activationState.rawValue)")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("Session watch state did change: \(session.activationState.rawValue)")
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        #if os(iOS)
        if let title = message["title"] as? String,
           let description = message["description"] as? String,
           let urlString = message["url"] as? String,
           let url = URL(string: urlString) {
            DispatchQueue.main.async {
                if UIApplication.shared.applicationState == .active {
                    print("Article URL opened")
                    NotificationCenter.default.post(
                        name: .articleSent,
                        object: nil,
                        userInfo: ["url": url]
                    )
                } else {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = description
                    content.userInfo = ["url": urlString]
                    content.sound = .default
                    
                    let request = UNNotificationRequest(
                        identifier: UUID().uuidString,
                        content: content,
                        trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    )
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        print(error?.localizedDescription ?? "Article notification Sent")
                    }
                }
                replyHandler(["articleURLOpened": true])
            }
        } else {
            replyHandler([:])
            
        }
        #endif
    }
    
    #if os(watchOS)
    func sendURLToiPhone(article: Article) {
        let message = [
            "title": "Tap to read article",
            "description": article.title,
            "url": article.articleURL.absoluteString
        ]
        
        self.isSending = true
        
        session.sendMessage(message) { replyHandler in
            print(replyHandler)
            DispatchQueue.main.async {
                self.isSending = false
            }
        } errorHandler: { error in
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.isSending = false
            }
        }
    }
    
    #endif
}

extension Notification.Name {
    
    static let articleSent = Notification.Name("ArticleSent")
}
