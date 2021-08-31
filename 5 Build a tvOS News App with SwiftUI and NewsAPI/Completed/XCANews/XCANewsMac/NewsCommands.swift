//
//  NewsCommands.swift
//  NewsCommands
//
//  Created by Alfian Losari on 7/25/21.
//

import SwiftUI

struct NewsCommands: Commands {
    
    var body: some Commands {
        CommandGroup(before: .sidebar) {
            BodyView()
                .keyboardShortcut("R", modifiers: [.command])
        }
    }
    
    struct BodyView: View {
        
        @FocusedValue(\.refreshAction) private var refreshAction: (() -> Void)?
        
        var body: some View {
            Button("Refresh News") {
                refreshAction?()
            }
        }
        
    }
    
}
