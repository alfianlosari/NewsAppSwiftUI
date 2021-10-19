//
//  XCANewsiOSWidget.swift
//  XCANewsiOSWidget
//
//  Created by Alfian Losari on 10/16/21.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct XCANewsiOSWidget: Widget {
    let kind: String = "XCANewsiOSWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectCategoryIntent.self, provider: ArticleProvider()) { entry in
            ArticleEntryWidgetView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
