//
//  XCANewsMacWidget.swift
//  XCANewsMacWidget
//
//  Created by Alfian Losari on 10/16/21.
//

import WidgetKit
import SwiftUI
import Intents


@main
struct XCANewsMacWidget: Widget {
    let kind: String = "XCANewsMacWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectCategoryIntent.self, provider: ArticleProvider()) { entry in
            ArticleEntryWidgetView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
