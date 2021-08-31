//
//  NewsAPIResponse.swift
//  XCANews
//
//  Created by Alfian Losari on 6/27/21.
//

import Foundation

struct NewsAPIResponse: Decodable {
    
    let status: String
    let totalResults: Int?
    let articles: [Article]?
    
    let code: String?
    let message: String?
    
}
