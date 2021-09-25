//
//  ComplicationController.swift
//  XCANewsWatch Extension
//
//  Created by Alfian Losari on 8/14/21.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    private let dataStore = ArticleDataStore()
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "XCA News", supportedFamilies: [
                .graphicRectangular,
                .modularLarge,
                .modularSmall
            ])
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration

    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        guard let article = dataStore.lastArticle,
              let template = makeTemplate(title: article.title, body: article.descriptionText, complication: complication)
        else {
            handler(nil)
            return
        }
        
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let text = "Latest news will appear here"
        let template = makeTemplate(title: "XCA News", body: text, complication: complication)
        handler(template)
    }
}

extension ComplicationController {
    
    func makeTemplate(
        title: String,
        body: String,
        complication: CLKComplication
    ) -> CLKComplicationTemplate? {
        switch complication.family {
            
        case .graphicRectangular:
            return CLKComplicationTemplateGraphicRectangularLargeView(
                headerTextProvider: CLKTextProvider(format: title, []),
                content: ComplicationView(text: body)
            )
            
        case .modularLarge:
            return CLKComplicationTemplateModularLargeStandardBody(
                headerTextProvider: CLKTextProvider(format: title, []),
                body1TextProvider: CLKTextProvider(format: body, [])
            )
            
        case .modularSmall:
            return CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKTextProvider(format: title, [])
            )
            
        default:
            return nil
            
        }
    }
    
}
